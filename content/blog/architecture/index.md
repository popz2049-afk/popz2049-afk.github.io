---
title: "Architecture Deep Dive: How the Deploy Kit Works"
date: 2026-02-27
draft: false
description: "A technical deep dive into the Zscaler Deploy Kit architecture -- modules, use cases, authentication, state management, Docker workflow, and TUI design."
summary: "Understand how the Deploy Kit is structured under the hood: the separation between base modules and additive use cases, OneAPI OAuth2 authentication flow, Terraform state management strategy, ZIA API rate limiting, Docker containerized workflow, and TUI architecture."
tags: ["architecture", "terraform", "design"]
categories: ["Technical"]
series: ["Zscaler Deploy Kit"]
showTableOfContents: true
---

This post explains how the Zscaler Deploy Kit is structured and why it was designed this way. Understanding the architecture helps you make informed decisions about customization, state management, and deployment strategy.

---

## High-Level Data Flow

```
                    +------------------------------------------+
                    |              USER                          |
                    +--------------------+---------------------+
                                         |
                    +--------------------v---------------------+
                    |         INTERACTION LAYER                  |
                    |                                            |
                    |   TUI (Textual)  |  AI Agent  |  CLI       |
                    |   tui/app.py     |  MCP Server|  terraform  |
                    +--------------------+---------------------+
                                         |
                    +--------------------v---------------------+
                    |         TERRAFORM ENGINE                   |
                    |                                            |
                    |   modules/zia/   <- Base infrastructure    |
                    |   modules/zpa/   <- Base infrastructure    |
                    |   modules/zdx/   <- Base infrastructure    |
                    |   use-cases/zia/ <- Additive policies      |
                    |   use-cases/zpa/ <- Additive policies      |
                    +--------------------+---------------------+
                                         |
                    +--------------------v---------------------+
                    |     ZSCALER TERRAFORM PROVIDERS            |
                    |                                            |
                    |   zscaler/zia (v2.5+)                      |
                    |   zscaler/zpa (latest)                     |
                    |   zscaler/zdx (latest)                     |
                    +--------------------+---------------------+
                                         |
                                         |  HTTPS / OAuth2
                                         |
                    +--------------------v---------------------+
                    |     ZSCALER ZERO TRUST EXCHANGE            |
                    |                                            |
                    |   ZIA Cloud  |  ZPA Cloud  |  ZDX Cloud    |
                    +------------------------------------------+
```

---

## Directory Structure Explained

```
zscaler-deploy-kit/
├── .env.example          # Template for API credentials
├── .env                  # Your actual credentials (gitignored)
├── .gitignore            # Protects sensitive files
├── variables.tf          # Centralized Terraform variables
├── requirements.txt      # Python dependencies (textual, rich, python-dotenv)
├── setup.sh              # macOS/Linux bootstrap script
├── setup.ps1             # Windows bootstrap script
│
├── modules/              # BASE INFRASTRUCTURE (your tenant's current config)
│   ├── zia/              #   ZIA resources: rules, settings, categories, etc.
│   │   ├── zia-provider.tf
│   │   ├── datasource.tf
│   │   ├── zia_url_filtering_rules.tf
│   │   ├── zia_firewall_filtering_rule.tf
│   │   ├── zia_ssl_inspection_rules.tf
│   │   └── ... (40+ resource files)
│   ├── zpa/              #   ZPA resources: segments, policies, connectors, etc.
│   │   ├── zpa-provider.tf
│   │   ├── datasource.tf
│   │   ├── zpa_application_segment.tf
│   │   ├── zpa_policy_access_rule.tf
│   │   └── ... (30+ resource files)
│   └── zdx/              #   ZDX resources: probes, applications
│       ├── zdx-provider.tf
│       └── zdx_applications.tf
│
├── use-cases/            # ADDITIVE POLICY PACKS (deploy on top of modules)
│   ├── catalog.json      #   Machine-readable index of all 23 use cases
│   ├── zia/              #   13 ZIA use cases (UC01-UC13)
│   │   ├── uc01_geo_access_control.tf
│   │   ├── uc02_saas_app_control.tf
│   │   └── ...
│   └── zpa/              #   10 ZPA use cases (UC01-UC10)
│       ├── uc01_contractor_browser_access.tf
│       ├── uc02_privileged_remote_access.tf
│       └── ...
│
├── tui/                  # TERMINAL USER INTERFACE (Textual-based)
│   ├── lib/              #   Shared libraries
│   └── screens/          #   TUI screen definitions
│
├── docker/               # CONTAINERIZED WORKFLOW
│   ├── Dockerfile        #   Ubuntu + Terraform + Zscaler Terraformer
│   ├── docker-compose.yml#   Full stack: Terraform + 2x ZPA Connectors + AdGuard DNS
│   └── connector-logs/   #   ZPA connector log volumes
│
├── scripts/              # UTILITY SCRIPTS
│   ├── deploy_docker_connector.ps1
│   ├── export_zdx.py
│   ├── find_pac_resource.py
│   ├── manage_zcc_profile.py
│   └── upload_pac.py
│
├── pac/                  # PAC (PROXY AUTO-CONFIG) FILES
│   ├── recommended.pac   #   Production PAC file
│   ├── kerberos.pac      #   Kerberos-aware PAC
│   ├── mobile_proxy.pac  #   Mobile-specific PAC
│   └── TF-PAC.pac        #   Terraform-managed PAC
│
├── docs/                 # DOCUMENTATION
│
└── marketing/            # MARKETING MATERIALS
```

---

## Modules vs. Use Cases

This is the key architectural distinction in the Deploy Kit.

### Modules (`modules/`)

Modules represent your **base infrastructure** -- the foundational Zscaler configuration for your tenant. This includes:

- Provider configuration and authentication
- Data sources (looking up existing groups, departments, categories)
- Core resources (URL filtering rules, firewall rules, SSL rules, app segments, access policies)
- Settings and advanced configuration (ATP, sandbox, security settings)

Modules are typically **imported from an existing tenant** using Zscaler Terraformer or built from scratch during initial deployment. They represent the steady-state configuration.

Each module directory (`modules/zia/`, `modules/zpa/`, `modules/zdx/`) has its own:
- Terraform provider configuration
- Terraform state file (`terraform.tfstate`)
- Data sources and outputs

### Use Cases (`use-cases/`)

Use cases are **additive policy packs** designed to be deployed on top of the base modules. They:

- Create new resources (rules, segments, policies) without modifying existing ones
- Deploy DISABLED by default for safe review
- Are self-contained in individual `.tf` files
- Can be deployed individually or in combination
- Are designed to be non-destructive (no `destroy` operations on base resources)

Use cases reference the base modules via data sources (e.g., looking up existing device groups, server groups, or policy sets).

### The Relationship

```
modules/zia/                    use-cases/zia/
+--------------------+         +--------------------+
| Base URL rules     |         | UC01: Geo blocking  |
| Base firewall      | <------ | UC02: SaaS control  |
| Base SSL           |  refs   | UC06: DNS security  |
| Device groups      |  via    | ...                 |
| Departments        |  data   |                     |
| Custom categories  | sources |                     |
+--------------------+         +--------------------+
     terraform.tfstate              (own state)
```

---

## Authentication

### OneAPI OAuth2 (Recommended)

All three Zscaler providers (ZIA, ZPA, ZDX) support **OneAPI OAuth2** authentication through ZIdentity. This is the modern, unified authentication method.

```
Environment Variables:
  ZSCALER_CLIENT_ID      -> OAuth2 Client ID (from ZIdentity > API Clients)
  ZSCALER_CLIENT_SECRET  -> OAuth2 Client Secret
  ZSCALER_VANITY_DOMAIN  -> Tenant domain (e.g., acme.zscaler.net)
  ZSCALER_CUSTOMER_ID    -> Customer ID (for MCP Server, optional for TF)
```

The Terraform providers pick up these environment variables automatically. No explicit provider configuration is needed:

```hcl
# zia-provider.tf -- no credentials hardcoded
provider "zia" {
}

# zpa-provider.tf -- no credentials hardcoded
provider "zpa" {
}
```

### OAuth2 Flow

```
1. Provider reads ZSCALER_CLIENT_ID + ZSCALER_CLIENT_SECRET
2. Provider calls ZIdentity token endpoint for ZSCALER_VANITY_DOMAIN
3. ZIdentity returns a short-lived bearer token
4. Provider uses bearer token for all API calls
5. Token auto-refreshes on expiry
```

### Legacy Authentication

For tenants not yet on ZIdentity, legacy per-service authentication is available:

```
ZIA_USERNAME, ZIA_PASSWORD, ZIA_API_KEY, ZIA_CLOUD
```

Set `ZSCALER_USE_LEGACY_CLIENT=true` to use legacy auth. This is not recommended for new deployments.

---

## State Management

Each module directory maintains its own Terraform state.

### State Files

```
modules/zia/terraform.tfstate          # ZIA base infrastructure state
modules/zpa/terraform.tfstate          # ZPA base infrastructure state
modules/zdx/terraform.tfstate          # ZDX base infrastructure state
use-cases/zia/terraform.tfstate        # ZIA use case state (if deployed from here)
use-cases/zpa/terraform.tfstate        # ZPA use case state (if deployed from here)
```

### Why Separate State Per Module?

1. **Isolation**: A failed ZPA apply does not corrupt ZIA state
2. **Permissions**: Different teams can manage ZIA vs. ZPA independently
3. **Speed**: Smaller state files mean faster plan/apply cycles
4. **Safety**: `terraform destroy` in one module does not affect others

### State Locking

Terraform creates a `.terraform.tfstate.lock.info` file during operations. If a previous run crashed:

1. Verify no other Terraform process is running
2. Delete the lock file: `rm .terraform.tfstate.lock.info`
3. Re-run your command

For team environments, use remote state backends (S3, Azure Blob, Terraform Cloud) with proper locking.

---

## ZIA API Rate Limiting and `-parallelism=1`

The ZIA API has strict rate limiting that affects Terraform operations:

- **Sequential processing**: ZIA processes API requests one at a time
- **~2 minutes per resource**: Complex resources (URL filtering rules, SSL rules) take 1-3 minutes each
- **Activation requirement**: ZIA changes require explicit activation after creation

### Why `-parallelism=1`?

By default, Terraform creates up to 10 resources in parallel. Against the ZIA API, this causes:
- HTTP 429 (Too Many Requests) errors
- Partial resource creation
- State inconsistencies
- Timeout failures (especially for URL filtering rules)

**Always use `-parallelism=1`** when running Terraform against ZIA:

```bash
terraform apply -parallelism=1
```

ZPA does **not** have this limitation. ZPA resources can be created with default parallelism.

### ZIA Activation

After Terraform creates ZIA resources, they exist in a "staged" state. To activate:

1. **Automatic**: Set `ZIA_ACTIVATION=true` in `.env` -- the provider activates after each apply
2. **Manual**: Run `terraform apply -target=zia_activation_status.activate` or click "Activate Changes" in the Admin Portal
3. **Terraform resource**: Include a `zia_activation_status` resource with `status = "ACTIVE"`

---

## Docker Alternative Workflow

The Docker workflow provides a containerized environment for Terraform operations and ZPA connector deployment.

### Architecture

```
docker-compose.yml
├── zscaler-terraform     # Ubuntu + Terraform + Zscaler Terraformer
│   └── Mounts: modules/, use-cases/, scripts/, .env
├── zpa-connector         # Official Zscaler ZPA Connector image
│   └── Uses: ZPA_PROVISIONING_KEY
├── zpa-connector-2       # Second connector (N+1 redundancy)
│   └── Uses: ZPA_PROVISIONING_KEY
└── adguard               # AdGuard Home DNS server
    └── Provides DNS for connectors (172.29.0.5)
```

### When to Use Docker

- **ZPA Connectors**: Running App Connectors in Docker for lab/home environments
- **CI/CD Pipelines**: Consistent Terraform environment across build agents
- **Air-gapped environments**: Pre-built image with all dependencies
- **Multi-tenant management**: Isolate credentials per container

### ZPA Connector Requirements

The ZPA connector Docker image requires elevated capabilities:

```yaml
cap_add:
  - NET_ADMIN       # Network management (tunnel creation)
  - NET_BIND_SERVICE # Bind to privileged ports
  - NET_RAW         # Raw socket access
  - SYS_NICE        # Process priority
  - SYS_TIME        # Time synchronization
  - SYS_RESOURCE    # Resource limits
```

### Running the Docker Stack

```bash
cd docker/

# Build the Terraform image
docker-compose build

# Start all services (Terraform shell + 2 connectors + DNS)
docker-compose up -d

# Enter the Terraform shell
docker exec -it zscaler-terraform bash

# Inside the container:
cd zia && terraform plan
```

---

## TUI Architecture

The Terminal User Interface is built with [Textual](https://textual.textualize.io/), a modern Python TUI framework.

### Components

```
tui/
├── app.py            # Main application entry point
├── lib/              # Shared libraries
│   ├── terraform.py  #   Terraform subprocess wrapper
│   ├── catalog.py    #   Use case catalog loader
│   └── env.py        #   .env file management
└── screens/          # Screen definitions
    ├── home.py       #   Dashboard / home screen
    ├── credentials.py#   Credential wizard
    ├── use_cases.py  #   Use case browser
    └── deploy.py     #   Deployment screen with plan/apply
```

### Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `textual` | >= 0.47.0 | TUI framework |
| `rich` | >= 13.0.0 | Rich text rendering |
| `python-dotenv` | >= 1.0.0 | .env file loading |

---

## Integration with Zscaler MCP Server

The Deploy Kit can work alongside the [Zscaler MCP Server](https://github.com/zscaler/zscaler-mcp-server) for AI-driven management:

```
AI Agent (Claude, Cursor, etc.)
    |
    ├── Zscaler MCP Server (read: 70+ tools, write: 34 tools)
    │   └── Real-time queries, policy creation, troubleshooting
    |
    └── Deploy Kit (Terraform)
        └── Bulk infrastructure, use case deployment, state management
```

The MCP Server is best for:
- Real-time queries ("list all URL filtering rules")
- Single-resource operations ("create a firewall rule")
- Troubleshooting ("why is this user being blocked?")

The Deploy Kit is best for:
- Bulk infrastructure deployment
- Repeatable, version-controlled configurations
- Compliance-driven policy sets
- CI/CD integration

Both use the same OneAPI OAuth2 credentials.
