---
title: "Cloud Browser Isolation: Secure Any Device, Any App"
date: 2026-02-27
draft: false
description: "How Zscaler's Browser Access and Cloud Browser Isolation products enable secure access for contractors, BYOD, and GenAI isolation -- with full Terraform automation."
summary: "Zscaler offers two complementary browser isolation products: ZPA Browser Access for clientless private app access and Cloud Browser Isolation (CBI) for internet traffic isolation. This post covers Turbo Mode, data controls, Smart Browser Isolation, and the Terraform resources that automate both products."
tags: ["browser-isolation", "cbi", "byod", "contractor", "browser-access"]
categories: ["Deep Dives"]
showTableOfContents: true
---

## Two Products, One Problem

Secure access has always been straightforward for managed devices with full agent deployments. Install Zscaler Client Connector, enforce device posture, and route all traffic through the Zero Trust Exchange. But not every access scenario involves a managed device.

Contractors working from personal laptops cannot install your agent. Employees on BYOD tablets need access to internal tools without full device enrollment. Third-party auditors require temporary access to specific applications. Kiosk devices in shared workspaces need locked-down browsing. In every case, you need secure access without an endpoint agent.

Zscaler addresses this with two complementary products that share the browser as the security boundary.

## ZPA Browser Access: Clientless Private App Access

**ZPA Browser Access** provides agent-free access to private web applications through the ZPA User Portal. A contractor navigates to your ZPA portal URL, authenticates against your IdP, and gains access to specific web applications rendered through an isolated browser session. No Client Connector installation required, no VPN, no network-level access.

From the user's perspective, it looks like a normal web application. From a security perspective, the user never touches your network. ZPA mediates every request through its cloud, applying access policies, logging all activity, and enforcing session controls. The application's real FQDN can be hidden from the user, preventing direct access attempts that bypass the isolation layer.

As of June 2025, ZPA Browser Access supports Zscaler-managed certificates, eliminating the operational overhead of provisioning and rotating certificates for browser-accessed applications.

## Cloud Browser Isolation: Rendering in the Cloud

**Cloud Browser Isolation (CBI)** takes a different approach. Instead of providing access to private applications, CBI isolates internet browsing by rendering web content in Zscaler's cloud and streaming only pixels to the user's browser. The user's endpoint never executes web content -- JavaScript, Flash, WebAssembly, and any embedded malware run in a disposable cloud container that is destroyed after the session.

### Turbo Mode

The historical criticism of browser isolation was performance. Early pixel-streaming implementations felt sluggish, with visible compression artifacts and noticeable latency. Zscaler addressed this in November 2024 with **Turbo Mode**, which uses WebGL acceleration to deliver up to 50 frames per second. The experience is effectively indistinguishable from native browsing for most web applications, including rich media and interactive dashboards.

### Data Controls

CBI provides granular controls over what users can do within isolated sessions:

- **Clipboard blocking** -- Prevent copy/paste of content between the isolated session and the local device
- **Download prevention** -- Block file downloads from isolated sites
- **Upload prevention** -- Block file uploads to isolated destinations
- **Print blocking** -- Disable printing from isolated sessions
- **Watermarking** -- Overlay user-identifying watermarks on rendered content to deter screenshots
- **Content Disarm and Reconstruction (CDR)** -- Sanitize downloaded files by stripping active content

These controls are policy-driven, so you can apply different restrictions to different user populations. Contractors might have all controls enabled. Internal employees accessing sanctioned SaaS might have only watermarking and clipboard restrictions.

### Smart Browser Isolation

**Smart Browser Isolation** uses AI to automatically determine which web traffic should be isolated based on risk signals. Instead of maintaining static lists of URLs to isolate, the system evaluates factors like domain age, reputation score, content category, and threat intelligence to make real-time isolation decisions. Newly registered domains, uncategorized sites, and pages with suspicious characteristics are automatically rendered in isolation without requiring manual policy updates.

## Terraform Resources

Both products are fully automatable through existing Zscaler Terraform resources.

**For ZPA Browser Access**, the `zpa_application_segment_browser_access` resource creates clientless application segments. This resource is already included in the Deploy Kit's base ZPA modules:

```hcl
resource "zpa_application_segment_browser_access" "contractor_portal" {
  name             = "Contractor-Document-Portal"
  domain_names     = ["docs.internal.example.com"]
  segment_group_id = data.zpa_segment_group.contractors.id
  # Browser Access-specific configuration
  clientless_app_id = "..."
}
```

**For CBI isolation policies**, two resources work together:

- **`zpa_policy_isolation_rule`** defines which ZPA access requests trigger browser isolation, using the `zpa_isolation_profile` data source to reference CBI profiles
- **`zia_url_filtering_rules`** with `action = "ISOLATE"` and a `cbi_profile` reference routes internet traffic through CBI based on URL category, user group, or other conditions
- **`zia_cloud_app_control_rule`** with `action = "ISOLATE"` applies isolation to specific cloud applications, including GenAI tools

## Use Cases

### Contractor Access

The most common deployment pattern combines ZPA Browser Access with CBI data controls. Contractors authenticate through the ZPA portal and access internal web applications in isolated sessions with clipboard blocking, download prevention, and watermarking enabled. They can view and interact with applications but cannot extract data to their unmanaged devices.

### BYOD

Employees on personal devices access corporate SaaS applications through CBI with selective controls. Full productivity tools are available, but sensitive actions (downloads, clipboard, printing) are restricted based on the application and user's department.

### GenAI Isolation

CBI isolation for generative AI tools is an emerging pattern. Instead of blocking ChatGPT or Copilot entirely, route AI traffic through CBI with upload prevention enabled. Users can interact with AI tools for general queries, but file uploads and clipboard paste operations are blocked, preventing sensitive data from reaching AI services. This pairs directly with the AI Security policies described in the [AI Security post](/blog/ai-security/).

For Deploy Kit users, browser isolation extends the zero trust model to every device and every user -- including those you cannot install an agent on. The Terraform resources make these policies as repeatable and auditable as the rest of your security stack.
