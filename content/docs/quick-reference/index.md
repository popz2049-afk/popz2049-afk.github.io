---
title: "Quick Reference"
date: 2026-02-27
draft: false
description: "Essential commands and workflows at a glance"
weight: 1
showTableOfContents: true
tags: ["terraform", "reference", "commands", "workflow"]
---

Everything you need at your fingertips — Terraform commands, TUI usage, Docker workflow, key file locations, and the step-by-step deployment process.

## Terraform Commands

### ZIA (Internet Access)

ZIA's API throttles aggressively. **Always use `-parallelism=1`** for all ZIA operations to avoid race conditions and 429 errors.

```bash
# Initialize the ZIA module
cd modules/zia
terraform init

# Plan changes (always parallelism=1 for ZIA)
terraform plan -parallelism=1

# Apply changes (always parallelism=1 for ZIA)
terraform apply -parallelism=1

# Destroy a single ZIA resource
terraform destroy -target=zia_url_filtering_rules.example -parallelism=1
```

> **Warning:** The ZIA provider auto-activates on apply. Changes go live on your tenant immediately — there is no staging environment.

### ZPA (Private Access)

ZPA's API handles concurrency well. Default parallelism is fine.

```bash
# Initialize the ZPA module
cd modules/zpa
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy a single ZPA resource
terraform destroy -target=zpa_application_segment.example
```

### General Terraform

```bash
# Validate configuration files
terraform validate

# Lint with TFLint
tflint

# List all resources in state
terraform state list

# Show details for a specific resource
terraform state show <resource_address>

# Import an existing resource into state
terraform import <resource_address> <id>

# Get the provider schema (ground truth when docs are wrong)
terraform providers schema -json
```

## TUI (Terminal User Interface)

The interactive TUI provides a guided deployment experience with built-in confirmation gates.

```bash
# Install Python dependencies
pip install -r requirements.txt

# Launch the TUI
python tui/app.py
```

The TUI walks through four stages:

1. **Credential setup** — validates your `.env` configuration
2. **Module selection** — choose ZIA, ZPA, or ZDX
3. **Use case browser** — browse, preview, and select use cases
4. **Deployment** — runs `terraform plan` and `apply` with confirmation gates

## Docker Usage

The Docker stack provides a containerized workflow with Terraform, ZPA connectors, and local DNS via AdGuard.

```bash
# Copy and configure credentials
cp .env.example .env
# Edit .env with your Zscaler credentials

# Build and launch the stack
cd docker
docker-compose up -d

# Enter the Terraform container
docker exec -it zscaler-terraform bash

# Inside the container, work in /workspace
cd /workspace/zia
terraform init
terraform plan -parallelism=1
```

### Docker Services

| Service | Purpose |
|---------|---------|
| `zscaler-terraform` | Terraform workspace (Ubuntu + Terraform 1.10.3 + Terraformer 2.1.7) |
| `zpa-connector` | ZPA App Connector #1 |
| `zpa-connector-2` | ZPA App Connector #2 |
| `adguard` | Local DNS for connectors (172.29.0.5) |

Volume mounts map `modules/`, `pac/`, `scripts/`, and `.env` into the container at `/workspace/`. Set `ZPA_PROVISIONING_KEY` in `.env` for the connectors.

## Key File Locations

| Path | Purpose |
|------|---------|
| `modules/zia/` | 47 ZIA Terraform configs (firewall, URL, SSL, DLP, ATP, forwarding, admin) |
| `modules/zia/INDEX.md` | ZIA resource index with file-to-resource mapping |
| `modules/zia/zia-provider.tf` | ZIA provider configuration |
| `modules/zia/datasource.tf` | ZIA data sources (departments, groups, etc.) |
| `modules/zpa/` | 30 ZPA Terraform configs (segments, policies, connectors, PRA, LSS) |
| `modules/zpa/INDEX.md` | ZPA resource index |
| `modules/zpa/zpa-provider.tf` | ZPA provider configuration |
| `modules/zpa/datasource.tf` | ZPA data sources (IdP, SAML, SCIM, posture) |
| `modules/zdx/` | ZDX templates (requires ZDX subscription) |
| `use-cases/zia/` | 13 ZIA use case `.tf` files (UC01 -- UC13) |
| `use-cases/zpa/` | 10 ZPA use case `.tf` files (UC01 -- UC10) |
| `tui/` | Python Textual TUI application |
| `pac/` | 4 PAC file templates |
| `scripts/` | Utility scripts (PAC upload, ZDX export, ZCC, Docker connector) |
| `docker/` | Docker Compose stack |
| `variables.tf` | Centralized Terraform variable definitions |
| `.env.example` | Credential template -- copy to `.env` and fill in |

## Environment Variables

### OneAPI OAuth2 (Recommended)

| Variable | Required | Description |
|----------|----------|-------------|
| `ZSCALER_CLIENT_ID` | Yes | OAuth2 Client ID from ZIdentity |
| `ZSCALER_CLIENT_SECRET` | Yes | OAuth2 Client Secret |
| `ZSCALER_VANITY_DOMAIN` | Yes | Your tenant domain (e.g., `acme.zscaler.net`) |
| `ZSCALER_CUSTOMER_ID` | Yes | Zscaler Customer ID |
| `ZSCALER_CLOUD` | Depends | Set to your cloud (e.g., `zscaler`). Check `.env.example` |

### Legacy Auth (Fallback)

If your tenant is not on ZIdentity yet, use legacy per-service credentials:

| Variable | Required | Description |
|----------|----------|-------------|
| `ZIA_USERNAME` | Yes | ZIA admin email |
| `ZIA_PASSWORD` | Yes | ZIA admin password |
| `ZIA_API_KEY` | Yes | ZIA API key |
| `ZIA_CLOUD` | Yes | Zscaler cloud name |
| `ZSCALER_USE_LEGACY_CLIENT` | Yes | Set to `true` |

### ZPA Variables (for Use Cases)

Several ZPA use cases require tenant-specific IDs:

| Variable | Required By | How to Get |
|----------|-------------|------------|
| `var.zpa_access_policy_set_id` | All access policy use cases | `terraform state show zpa_policy_access_rule.<name>` or ZPA Admin Console |
| `var.zpa_default_server_group_id` | App segment use cases | `terraform state list \| grep server_group` |
| `var.zpa_posture_profile_udid` | Posture/compliance use cases (UC04, UC09, UC10) | `terraform state show zpa_posture_profile.<name>` |

## Use Case Deployment Steps

Follow this exact sequence for every use case deployment. Do not skip steps.

### 1. Review the Use Case

Read the `.tf` file in `use-cases/zia/` or `use-cases/zpa/`. Understand what resources it creates, what it blocks, and what variables it needs.

### 2. Copy to the Target Module Directory

```bash
# Example: deploy ZIA use case 05 (Threat Lockdown)
cp use-cases/zia/uc05_threat_lockdown.tf modules/zia/
```

### 3. Set Required Variables

Some use cases reference variables. Check the file header for requirements and add values to `variables.tf` or a `.tfvars` file.

### 4. Plan

```bash
cd modules/zia
terraform plan -parallelism=1   # ZIA — always parallelism=1

# or for ZPA:
cd modules/zpa
terraform plan                  # ZPA — default parallelism OK
```

### 5. Review the Plan Output

Carefully inspect the plan. Count the resources being added, changed, and destroyed. Make sure nothing unexpected is being modified.

### 6. Apply

```bash
terraform apply -parallelism=1  # ZIA
# or
terraform apply                 # ZPA
```

### 7. Verify

Check the Zscaler admin console to confirm resources were created in **DISABLED** state. All use cases deploy disabled by default — this is a safety feature. Enable them after review via the admin console or by changing `state` to `"ENABLED"` in the `.tf` file.

## Resource Naming Conventions

| Prefix | Meaning | Example |
|--------|---------|---------|
| `BP-*` | Best Practice baseline rule (base modules) | `BP-Block-Malware-Sites` |
| `UC-ZIA-NN-*` | ZIA use case resource | `UC01-Geo-Block-High-Risk-Countries` |
| `UC-ZPA-NN-*` | ZPA use case resource | `UC01-Contractor-Web-Portal` |
| `CMMC-*` | CMMC/NIST compliance resource | `CMMC-CUI-Boundary-Enforce` |

## Utility Scripts

| Script | Command | Purpose |
|--------|---------|---------|
| Upload PAC file | `python scripts/upload_pac.py` | Push PAC file to Zscaler |
| Export ZDX config | `python scripts/export_zdx.py` | Export ZDX configuration |
| Manage ZCC profiles | `python scripts/manage_zcc_profile.py` | Client Connector profile management |
| Deploy Docker connector | `scripts/deploy_docker_connector.ps1` | Deploy ZPA Docker connector |
