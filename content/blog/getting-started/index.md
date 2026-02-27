---
title: "Getting Started: Zero to First Deploy"
date: 2026-02-27
draft: false
description: "A step-by-step guide from zero to your first Zscaler deployment using Infrastructure-as-Code with the Deploy Kit."
summary: "Walk through every step from API credential setup to deploying your first use case. Covers prerequisites, setup scripts, TUI launch, and a recommended first deployment with verification in the Admin Portal."
tags: ["tutorial", "getting-started", "terraform", "setup"]
categories: ["Tutorials"]
showTableOfContents: true
---

Whether you are new to Zscaler Terraform automation or just getting started with the Deploy Kit, this guide walks you through every step from obtaining your API credentials to verifying your first deployment in the Admin Portal. By the end, you will have a working Infrastructure-as-Code pipeline for your Zscaler tenant.

---

## Prerequisites

Before you begin, ensure you have:

| Requirement | Minimum Version | Check Command |
|-------------|----------------|---------------|
| **Terraform** | 1.5+ | `terraform version` |
| **Python** | 3.10+ | `python3 --version` |
| **Zscaler Tenant** | ZIA and/or ZPA | Admin Portal login |
| **ZIdentity** | OneAPI OAuth2 enabled | ZIdentity console access |

Optional:
- **Docker** (for containerized workflow or ZPA connectors)
- **Zscaler Client Connector** (for testing policies locally)
- **Git** (for version control)

---

## Step 1: Get Your API Credentials

The Deploy Kit uses **OneAPI OAuth2** authentication, which is the modern unified auth method for all Zscaler services.

### Create an API Client

1. Log in to your **Zscaler Admin Portal**
2. Navigate to **Administration > ZIdentity Admin Console** (or go directly to your ZIdentity URL)
3. Go to **Integration > API Clients**
4. Click **Create API Client**
5. Configure:
   - **Name**: `deploy-kit-terraform` (or any descriptive name)
   - **Scopes**: Select the products you need:
     - `zia` -- Internet Access management
     - `zpa` -- Private Access management
     - `zdx` -- Digital Experience (read-only)
   - **Role**: `Super Admin` (for initial setup; scope down later)
6. Click **Create**
7. **Copy the Client ID and Client Secret immediately** -- the secret is only shown once

### Gather Your Tenant Info

You will also need:
- **Vanity Domain**: Your tenant URL (e.g., `acme.zscaler.net` or `acme.zscloud.net`)
- **Customer ID**: Found in Administration > Company Profile, or in the ZIdentity console

### Note on ZSCALER_CLOUD

The `ZSCALER_CLOUD` environment variable tells the provider which Zscaler cloud instance to target. Common values:

| Cloud | Domain Pattern |
|-------|---------------|
| `zscaler` | `*.zscaler.net` |
| `zscalerone` | `*.zscalerone.net` |
| `zscalertwo` | `*.zscalertwo.net` |
| `zscalerthree` | `*.zscalerthree.net` |
| `zscloud` | `*.zscloud.net` |
| `zscalerbeta` | `*.zscalerbeta.net` |
| `zscalergov` | `*.zscalergov.net` |

**Important**: If you are using OneAPI OAuth2 (recommended), do NOT set `ZSCALER_CLOUD` unless specifically needed. The provider auto-detects from the vanity domain. Setting it incorrectly causes authentication failures.

---

## Step 2: Run the Setup Script

Clone or download the Deploy Kit, then run the appropriate setup script for your platform.

### macOS / Linux

```bash
chmod +x setup.sh
./setup.sh
```

### Windows (PowerShell)

```powershell
.\setup.ps1
```

### What the Setup Script Does

1. Checks for Terraform (installs if missing via brew/apt/yum/winget)
2. Checks for Python 3.10+ (installs if missing on Windows)
3. Creates a Python virtual environment (`.venv/`)
4. Installs Python dependencies (`textual`, `rich`, `python-dotenv`)
5. Copies `.env.example` to `.env` if no `.env` exists
6. Runs `terraform init` in each module directory

---

## Step 3: Configure Your Credentials

Edit the `.env` file with your API credentials:

```bash
# Required -- OneAPI OAuth2
ZSCALER_CLIENT_ID=your-oauth-client-id
ZSCALER_CLIENT_SECRET=your-oauth-client-secret
ZSCALER_VANITY_DOMAIN=your-tenant.zscaler.net
ZSCALER_CUSTOMER_ID=your-customer-id

# Optional
ZIA_ACTIVATION=true
```

The Terraform providers read credentials from environment variables automatically. The `.env` file is loaded by the TUI and scripts via `python-dotenv`.

**Security**: The `.env` file is in `.gitignore` and will never be committed. Never share your client secret.

---

## Step 4: Launch the TUI

The Terminal User Interface (TUI) is the recommended way to interact with the Deploy Kit.

```bash
# Activate the virtual environment first
source .venv/bin/activate        # macOS/Linux
.venv\Scripts\Activate.ps1       # Windows

# Launch the TUI
python tui/app.py
```

The TUI provides:
- **Credential wizard**: Guided setup for `.env` configuration
- **Use case browser**: Browse all 23 use cases with descriptions
- **One-click deploy**: Select a use case and deploy it
- **Status dashboard**: See what is currently deployed

---

## Step 5: Browse Use Cases

The Deploy Kit includes **23 pre-built use cases** organized by product and category:

| Product | Standard | Compliance | Total |
|---------|----------|------------|-------|
| ZIA (Internet Access) | 8 | 5 | 13 |
| ZPA (Private Access) | 8 | 2 | 10 |
| **Total** | **16** | **7** | **23** |

Each use case is a self-contained Terraform file that creates specific Zscaler resources (URL filtering rules, firewall rules, access policies, etc.). All use cases deploy in a **DISABLED** state by default so you can review them in the Admin Portal before enabling.

See the [Use Case Guide](/blog/use-case-guide/) for detailed descriptions of every use case.

---

## Step 6: Deploy Your First Use Case

We recommend starting with **UC-06: DNS Security Enforcement** because:
- It is low-risk (only creates firewall DNS rules and URL filters)
- It does not require any prerequisites (no device groups, connector groups, etc.)
- It deploys DISABLED so nothing is active until you manually enable it
- It demonstrates the core Deploy Kit workflow

### Deploy via CLI

```bash
cd use-cases/zia

# Preview what will be created
terraform plan -var-file=../../.env

# Deploy (creates resources in DISABLED state)
terraform apply -parallelism=1 -target=module.uc06_dns_security
```

### Deploy via TUI

1. Launch `python tui/app.py`
2. Navigate to **Use Cases > ZIA Standard**
3. Select **UC-06: DNS Security Enforcement**
4. Click **Deploy**
5. Review the plan output
6. Confirm

### Why `-parallelism=1` for ZIA?

The ZIA API has strict rate limiting and processes resources sequentially. Running parallel Terraform operations against ZIA causes timeouts and failures. Always use `-parallelism=1` for ZIA modules. ZPA does not have this limitation.

---

## Step 7: Verify in the Admin Portal

After deploying:

1. Log in to your **Zscaler Admin Portal**
2. For ZIA use cases:
   - Go to **Policy > URL & Cloud App Control** (for URL filtering rules)
   - Go to **Policy > Firewall Control** (for firewall rules)
   - Go to **Policy > SSL Inspection** (for SSL rules)
   - Go to **Policy > Data Loss Prevention** (for DLP rules)
3. For ZPA use cases:
   - Go to **Policy > Access Policy** (for access rules)
   - Go to **Applications > Application Segments** (for app segments)
   - Go to **Infrastructure > App Connectors** (for connector groups)

You should see the newly created resources with the prefix from the use case (e.g., `[UC06]` or `[DeployKit]`). They will be in a **DISABLED** state.

### Enabling a Use Case

1. Click on the rule/resource in the Admin Portal
2. Toggle the **Status** to **Enabled**
3. Click **Save**
4. For ZIA: Click **Activate Changes** (the banner at the top of the page)

Alternatively, update the Terraform file to change `state = "DISABLED"` to `state = "ENABLED"` and run `terraform apply` again.

---

## What to Do Next

### Immediate Next Steps

1. **Review all deployed resources** in the Admin Portal before enabling anything
2. **Customize** the use case variables (IP ranges, domain lists, group names) to match your environment
3. **Deploy additional use cases** that match your security requirements
4. **Set up the Docker workflow** if you need ZPA connectors (see [Architecture Deep Dive](/blog/architecture/))

### Recommended Deployment Order

For a typical enterprise deployment:

1. **ZIA Foundation**: UC-08 (SSL Inspection) + UC-06 (DNS Security)
2. **ZIA Protection**: UC-01 (Geo Blocking) + UC-02 (SaaS Control) + UC-07 (Cloud DLP)
3. **ZPA Foundation**: UC-06 (App Discovery) to map your internal apps
4. **ZPA Segmentation**: UC-03 (Department Segmentation) + UC-04 (Posture-Driven Access)
5. **Compliance**: UC-09 through UC-12 (CMMC) or UC-10/ZPA (EO 14028) as needed

### Learn More

- [Use Case Guide](/blog/use-case-guide/) -- Detailed descriptions of all 23 use cases
- [Architecture Deep Dive](/blog/architecture/) -- How the kit works under the hood
- [Best Practices](/blog/best-practices/) -- Zscaler deployment best practices
- [Troubleshooting](/blog/troubleshooting/) -- Common issues and fixes
