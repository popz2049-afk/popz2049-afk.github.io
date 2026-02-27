---
title: "Zscaler API Quirks & Gotchas"
date: 2026-02-27
draft: false
description: "Hard-won lessons from live Zscaler Terraform deployments"
weight: 2
showTableOfContents: true
tags: ["terraform", "api", "zia", "zpa", "troubleshooting"]
---

Every item on this page was discovered the hard way during live Terraform deployments against real Zscaler tenants. Bookmark this page and review it before your first deployment -- it will save you hours of debugging.

## ZIA API Behavior

### Rate Limiting and Parallelism

The ZIA API throttles aggressively. Running Terraform with default parallelism (10) causes race conditions and HTTP 429 errors.

**Always use `-parallelism=1` for all ZIA operations:**

```bash
terraform plan -parallelism=1
terraform apply -parallelism=1
```

ZPA does not have this limitation. Default parallelism is fine for ZPA.

### Auto-Activation on Apply

When you run `terraform apply` against ZIA modules, the provider auto-activates your changes. This means **changes go live on your tenant immediately** -- there is no staging environment or approval gate at the API level.

This is why the Deploy Kit uses a strict plan-review-apply workflow with all use cases deploying in `DISABLED` state.

### Mid-Apply Interrupts and API Locks

If you kill a `terraform apply` mid-run (Ctrl+C, terminal crash, etc.), the ZIA API retains a lock on your session.

**Workaround:** Wait approximately 60 seconds for the lock to auto-release, then retry your operation. Do not attempt to force a new apply immediately -- it will fail with a lock conflict.

### Concurrent Apply Conflicts

Never run two ZIA applies simultaneously against the same tenant. The provider's auto-activation means concurrent applies will conflict with each other, leading to unpredictable state.

## ZIA-Specific Gotchas

### URL Filtering + NEWLY_REGISTERED_DOMAIN

Including the `NEWLY_REGISTERED_DOMAIN` category in URL filtering rules causes the API to time out.

**Workaround:** Remove this category from URL filter rules entirely. If you need to block newly registered domains, use firewall rules instead.

### SSL Rule Name Length

SSL rule names have a **maximum of 31 characters**. The API rejects longer names silently -- you will not get an error message, but the rule will not be created.

**Workaround:** Keep SSL rule names short. Use abbreviations when needed.

```hcl
# Bad -- 35 characters, will be silently rejected
resource "zia_ssl_inspection_rules" "example" {
  name = "Block-Untrusted-Certificates-Rule"
  # ...
}

# Good -- 28 characters, within the limit
resource "zia_ssl_inspection_rules" "example" {
  name = "Block-Untrusted-Certs-Rule"
  # ...
}
```

### Country Code Format for dest_countries

The `dest_countries` field requires a specific format: ISO 3166-1 alpha-2 codes prefixed with `COUNTRY_`.

```hcl
# Wrong -- these will all fail
dest_countries = ["China", "CN", "RU", "Russia"]

# Correct
dest_countries = ["COUNTRY_CN", "COUNTRY_RU", "COUNTRY_IR"]
```

### Provider Documentation vs. Reality

The official Zscaler Terraform provider documentation is frequently wrong or outdated for ZIA resources. When in doubt, use the provider schema as your source of truth:

```bash
terraform providers schema -json | jq '.provider_schemas'
```

This gives you the actual attributes, types, and nesting structure the provider expects -- not what the docs say it expects.

## ZIA Provider Schema Gotchas

These are the most common mistakes when writing ZIA Terraform configurations. The left column is what you would expect based on documentation or intuition. The right column is what actually works.

### SSL Inspection Action Blocks

**What you expect:** The `action {}` block in SSL inspection rules has flat attributes for SSL settings.

**What it actually is:** SSL settings are nested inside `decrypt_sub_actions {}` and `do_not_decrypt_sub_actions {}` sub-blocks.

```hcl
# Wrong -- flat attributes in action
resource "zia_ssl_inspection_rules" "example" {
  name = "Example-SSL-Rule"
  action {
    min_tls_version = "TLS_1_2"  # Not valid here
    type = "SSL"                  # Not a valid attribute at all
  }
}

# Correct -- nested sub-actions
resource "zia_ssl_inspection_rules" "example" {
  name = "Example-SSL-Rule"
  action {
    decrypt_sub_actions {
      min_server_tls_version = "TLS_1_2"
    }
  }
}
```

Key differences:
- `min_tls_version` is actually `min_server_tls_version` and lives inside `decrypt_sub_actions`
- `type = "SSL"` is not a valid attribute -- remove it entirely

### Bandwidth Class ID Type

**What you expect:** `id = 1` (a single number).

**What it actually is:** `id = [1]` (a set of numbers).

```hcl
# Wrong
bandwidth_class {
  id = 1
}

# Correct
bandwidth_class {
  id = [1]
}
```

### DNS Rules: URL Categories vs. Destination IP Categories

**What you expect:** DNS rules use `url_categories` to match traffic categories.

**What it actually is:** DNS rules use `dest_ip_categories`.

```hcl
# Wrong
resource "zia_firewall_dns_rule" "example" {
  url_categories = ["ADULT_CONTENT"]  # Wrong attribute name
}

# Correct
resource "zia_firewall_dns_rule" "example" {
  dest_ip_categories = ["ADULT_CONTENT"]
}
```

### Sandbox Quarantine Action

**What you expect:** `action = "QUARANTINE"` for sandbox quarantine behavior.

**What it actually is:** `ba_rule_action = "BLOCK"` combined with `first_time_operation = "QUARANTINE"`.

```hcl
# Wrong
resource "zia_sandbox_behavioral_analysis" "example" {
  action = "QUARANTINE"
}

# Correct
resource "zia_sandbox_behavioral_analysis" "example" {
  ba_rule_action      = "BLOCK"
  first_time_operation = "QUARANTINE"
}
```

### File Type Filtering Action

**What you expect:** `action = "BLOCK"` for file type rules.

**What it actually is:** `filtering_action = "BLOCK"`.

```hcl
# Wrong
resource "zia_file_type_control_rules" "example" {
  action = "BLOCK"
}

# Correct
resource "zia_file_type_control_rules" "example" {
  filtering_action = "BLOCK"
}
```

### File Type Enum Values

**What you expect:** Simple names like `EXE`, `DLL`, `MSI`.

**What it actually is:** Category-based names like `FTCATEGORY_WINDOWS_EXECUTABLES`, `FTCATEGORY_MICROSOFT_INSTALLER`.

```hcl
# Wrong
file_types = ["EXE", "DLL", "MSI"]

# Correct
file_types = ["FTCATEGORY_WINDOWS_EXECUTABLES", "FTCATEGORY_MICROSOFT_INSTALLER"]
```

### IPS Action Values

**What you expect:** `action = "BLOCK"`.

**What it actually is:** The valid values are `ALLOW`, `BLOCK_DROP`, `BLOCK_RESET`, and `BYPASS_IPS`. There is no plain `BLOCK`.

```hcl
# Wrong
action = "BLOCK"

# Correct -- choose one
action = "BLOCK_DROP"   # Drop the packet silently
action = "BLOCK_RESET"  # Reset the connection
```

### Resource Name Mismatches

Several ZIA resource names differ from what you would expect:

| What You Might Search For | Actual Resource Name |
|---------------------------|---------------------|
| `zia_firewall_filtering_ip_destination_groups` | `zia_firewall_filtering_destination_groups` |
| `zia_activation` | `zia_activation_status` (with `status = "ACTIVE"`) |

```hcl
# Wrong resource name
resource "zia_activation" "activate" {}

# Correct resource name
resource "zia_activation_status" "activate" {
  status = "ACTIVE"
}
```

## ZPA-Specific Gotchas

### Policy Set ID is Tenant-Specific

The `policy_set_id` is different for every tenant and for every policy type (access, timeout, forwarding, etc.). Never hardcode it.

**Workaround:** Always look it up dynamically from Terraform state or use data sources:

```bash
# From state
terraform state show zpa_policy_access_rule.<name>

# From the admin console
# ZPA Admin Console > Policy > Access Policy > check the URL
```

Or use the `zpa_policy_type` data source:

```hcl
data "zpa_policy_type" "access" {
  policy_type = "ACCESS_POLICY"
}

resource "zpa_policy_access_rule" "example" {
  policy_set_id = data.zpa_policy_type.access.id
  # ...
}
```

## Debugging Checklist

When a Terraform operation fails against the Zscaler API, work through this list:

1. **Check parallelism** -- Are you using `-parallelism=1` for ZIA?
2. **Check for API locks** -- Did a previous apply fail mid-run? Wait 60 seconds.
3. **Check the provider schema** -- `terraform providers schema -json` is the source of truth.
4. **Check resource names** -- The actual resource type may differ from what you expect.
5. **Check attribute names** -- Many attributes have non-obvious names (see the schema gotchas above).
6. **Check enum values** -- Use the exact string values the API expects, not human-readable names.
7. **Check string lengths** -- SSL rule names max out at 31 characters.
8. **Check country code format** -- Use `COUNTRY_XX` format, not ISO codes alone.
9. **Check nesting** -- Some attributes are nested inside sub-blocks that the docs do not mention.
10. **Run `terraform validate`** -- Catches syntax and type errors before you hit the API.
