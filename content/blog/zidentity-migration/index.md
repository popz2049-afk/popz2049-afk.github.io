---
title: "Migrating to ZIdentity: From Legacy Auth to OneAPI"
date: 2026-02-27
draft: false
description: "A practical guide to migrating from Zscaler's legacy per-product authentication to the unified ZIdentity OneAPI OAuth2 flow, including Terraform provider configuration and migration deadlines."
summary: "Zscaler is deprecating legacy per-product authentication in favor of ZIdentity, a centralized OAuth2 identity service. This guide covers what ZIdentity changes, the OneAPI authentication flow, Terraform provider v4.0.0+ configuration, migration steps, key deadlines, and how the Deploy Kit supports both authentication methods."
tags: ["zidentity", "oneapi", "authentication", "migration", "oauth2"]
categories: ["Guides"]
series: ["Zscaler Deploy Kit"]
showTableOfContents: true
---

## The Legacy Authentication Problem

Historically, each Zscaler product maintained its own authentication mechanism. ZIA required a username, password, and API key. ZPA used a client ID and client secret scoped to ZPA only. ZDX had its own credential set. If you managed all three products -- which most organizations do -- you maintained three separate sets of credentials, each with its own rotation schedule, its own admin portal for management, and its own failure modes.

For Terraform users, this meant configuring each provider independently:

```hcl
# Legacy ZIA -- three separate credential fields
provider "zia" {
  username = var.zia_username
  password = var.zia_password
  api_key  = var.zia_api_key
  cloud    = var.zia_cloud
}

# Legacy ZPA -- different credential fields entirely
provider "zpa" {
  client_id     = var.zpa_client_id
  client_secret = var.zpa_client_secret
  customer_id   = var.zpa_customer_id
  cloud         = var.zpa_cloud
}
```

This fragmentation created operational overhead (credential sprawl), security risk (more credentials to manage and rotate), and integration complexity (different auth flows for different products).

## What ZIdentity Changes

**ZIdentity** is Zscaler's centralized identity service that unifies authentication across the entire platform. Instead of per-product credentials, you create a single API client in ZIdentity with scoped permissions across ZIA, ZPA, ZDX, and any future Zscaler services.

Key capabilities include:

- **Single OAuth2 token endpoint** for all Zscaler products, accessible via your tenant's vanity domain at `<vanity>.zslogin.net`
- **Built-in MFA** supporting SMS, email, TOTP, and FIDO/passkeys for interactive logins
- **External IdP federation** via SAML and OIDC with Entra ID, Okta, and Ping Identity
- **SCIM provisioning** for automated user lifecycle management
- **Centralized RBAC** across ZIA, ZPA, and ZDX from a single management plane

## The OneAPI OAuth2 Flow

OneAPI is the authentication protocol that ZIdentity exposes. For Terraform and other API integrations, it uses the standard OAuth2 client credentials flow:

1. You create an API client in ZIdentity with a `client_id` and `client_secret`
2. Your integration (Terraform provider, script, MCP server) sends these credentials to `https://<vanity>.zslogin.net/oauth2/token`
3. ZIdentity validates the credentials and returns a short-lived bearer token
4. The bearer token is used for all subsequent API calls to ZIA, ZPA, and ZDX
5. The token auto-refreshes on expiry -- no manual rotation required

The critical improvement is that one credential pair authenticates to all products. Scope is controlled at the API client level in ZIdentity, not at the credential level.

## Terraform Provider v4.0.0+ Configuration

All three Zscaler Terraform providers (ZIA, ZPA, ZDX) support ZIdentity natively starting with version 4.0.0. The provider configuration is identical across all three:

```hcl
# OneAPI -- same four variables for ZIA, ZPA, and ZDX
# Set as environment variables:
#   ZSCALER_CLIENT_ID
#   ZSCALER_CLIENT_SECRET
#   ZSCALER_VANITY_DOMAIN
#   ZSCALER_CLOUD

provider "zia" {}
provider "zpa" {}
provider "zdx" {}
```

With OneAPI, the providers pick up credentials from environment variables automatically. No explicit configuration is needed in the provider blocks. This is cleaner, more secure (no credentials in code), and consistent across all products.

For tenants still on legacy auth, the providers support backward compatibility:

```hcl
provider "zia" {
  use_legacy_client = true
}
```

Set `ZSCALER_USE_LEGACY_CLIENT=true` in your environment alongside the legacy ZIA/ZPA credential variables.

## Migration Steps

The migration from legacy to ZIdentity follows this sequence:

1. **Verify your tenant supports ZIdentity.** Check with your Zscaler account team or look for the ZIdentity option in your admin portal.
2. **Create an API client in ZIdentity.** Navigate to ZIdentity > API Clients, create a new client, and assign it the appropriate scopes for ZIA, ZPA, and ZDX administration.
3. **Record the `client_id` and `client_secret`.** The secret is shown only once at creation time.
4. **Update your `.env` file.** Replace the legacy credential variables with the OneAPI variables (`ZSCALER_CLIENT_ID`, `ZSCALER_CLIENT_SECRET`, `ZSCALER_VANITY_DOMAIN`, `ZSCALER_CLOUD`). Remove or comment out the legacy variables.
5. **Update Terraform provider versions.** Ensure all providers are at v4.0.0 or later in your `required_providers` block.
6. **Test with `terraform plan`.** Run a plan against each module to verify authentication works. No resource changes should appear -- only the auth method changes.
7. **Remove `use_legacy_client` flags** once you have confirmed OneAPI works.

## Critical Deadlines

Zscaler has published a firm migration timeline:

| Date | Milestone |
|------|-----------|
| **March 2026** | Complete migration -- all tenants expected to have ZIdentity enabled |
| **April 2026** | New features exclusive to Experience Center (ZIdentity-based admin portal) |
| **September 2026** | Legacy admin UIs deprecated -- ZIdentity becomes the only authentication path |

Organizations that have not migrated by September 2026 will lose access to legacy admin portals and API authentication methods. Terraform configurations using legacy credentials will stop working.

## How the Deploy Kit Supports Both Methods

The Zscaler Deploy Kit's `.env.example` file includes configuration blocks for both authentication methods. The provider configurations in `modules/zia/zia-provider.tf`, `modules/zpa/zpa-provider.tf`, and `modules/zdx/zdx-provider.tf` are designed to work with environment variables, making the switch from legacy to OneAPI a matter of updating your `.env` file without modifying any Terraform code.

If you are starting a new deployment today, use OneAPI exclusively. If you are maintaining an existing deployment on legacy auth, plan your migration now. The March 2026 deadline is imminent, and the September 2026 deprecation is non-negotiable.
