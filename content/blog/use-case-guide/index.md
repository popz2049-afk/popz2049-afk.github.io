---
title: "The Complete Use Case Guide: 23 Terraform Configs Explained"
date: 2026-02-27
draft: false
description: "Complete reference for all 23 pre-built Zscaler use cases covering ZIA, ZPA, standard security, and compliance scenarios."
summary: "A comprehensive reference for every use case in the Deploy Kit -- 13 ZIA and 10 ZPA configurations covering geo-blocking, SaaS control, DLP, SSL inspection, CMMC compliance, Zero Trust architecture, and more. Each entry details what it creates, why, and how to customize it."
tags: ["use-cases", "terraform", "zia", "zpa", "compliance"]
categories: ["Guides"]
showTableOfContents: true
---

This is the complete reference for all 23 use cases in the Zscaler Deploy Kit. Whether you are looking for a specific security control, evaluating which use cases to deploy, or building a compliance package, this guide covers every configuration in detail.

Each use case is a self-contained Terraform file that creates specific Zscaler resources. All use cases deploy **DISABLED** by default unless noted otherwise. They are designed to be additive -- they create new resources on top of your base infrastructure without modifying what already exists.

---

## How Use Cases Work

- Each use case is a `.tf` file in `use-cases/zia/` or `use-cases/zpa/`
- Use cases are **additive** -- they create new resources on top of the base infrastructure in `modules/`
- All resources are prefixed with a use case identifier (e.g., `[UC06]`) for easy identification
- The `use-cases/catalog.json` file contains machine-readable metadata for all use cases
- Use cases can be deployed individually or in combination

### Deployment States

| State | Meaning |
|-------|---------|
| `DISABLED` | Resource is created but not active. Safe to deploy and review first. |
| `ENABLED` | Resource is active and processing traffic immediately. |

Most use cases default to DISABLED. The exception is UC-13 (iOS Strict Enforcement) which deploys ENABLED because iOS strict enforcement requires active policies to function.

---

## ZIA Standard Use Cases (8)

### ZIA-01: Geo-Based Access Control

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc01_geo_access_control.tf` |
| **Product** | ZIA |
| **Category** | Standard |
| **Difficulty** | Basic |
| **Resources Created** | 3 |
| **Resource Types** | `zia_url_filtering_rules`, `zia_firewall_filtering_rule` |
| **Compliance** | -- |
| **Prerequisites** | None |

**What it does**: Blocks or restricts traffic to and from high-risk countries. Creates URL filtering rules with geo-based restrictions and firewall rules that block traffic from sanctioned and watchlist nations. Useful for organizations that need to comply with OFAC sanctions or simply want to reduce attack surface from high-risk geographies.

**Resources created**:
- URL filtering rule: Block browsing to high-risk country domains
- URL filtering rule: Caution page for watchlist countries
- Firewall rule: Block all outbound traffic to sanctioned nations

**Customization points**:
- Country lists (sanctioned vs. watchlist)
- Action per country tier (BLOCK vs. CAUTION vs. ALLOW)
- Exempt groups (international business teams)

---

### ZIA-02: SaaS Application Control

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc02_saas_app_control.tf` |
| **Product** | ZIA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 4 |
| **Resource Types** | `zia_url_filtering_rules` |
| **Compliance** | -- |
| **Prerequisites** | None |

**What it does**: Controls which SaaS applications are allowed, blocked, or cautioned. Blocks personal cloud storage (Dropbox, Google Drive personal) and consumer messaging apps. Puts a caution page on unsanctioned SaaS tools while allowing corporate-sanctioned collaboration platforms (Slack, Teams, approved CRM).

**Resources created**:
- URL filtering rule: Block personal cloud storage
- URL filtering rule: Block consumer messaging
- URL filtering rule: Caution on unsanctioned SaaS
- URL filtering rule: Allow corporate-sanctioned tools

**Customization points**:
- Sanctioned vs. unsanctioned app lists
- User groups exempt from restrictions
- Caution vs. block for shadow IT

---

### ZIA-03: Time-Based Browsing Control

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc03_time_based_access.tf` |
| **Product** | ZIA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 3 |
| **Resource Types** | `zia_url_filtering_rules` |
| **Compliance** | -- |
| **Prerequisites** | None |

**What it does**: Allows social media and streaming only during non-business hours. Blocks social media and gaming categories during business hours (8am-5pm Monday-Friday) and displays a caution page for streaming services. Outside business hours, these categories are allowed.

**Resources created**:
- URL filtering rule: Block social media during business hours
- URL filtering rule: Block gaming during business hours
- URL filtering rule: Caution on streaming during business hours

**Customization points**:
- Business hours definition (start time, end time, days)
- Time zone
- Category list per time window
- User group exemptions (marketing team may need social media)

---

### ZIA-04: BYOD / Guest Network Isolation

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc04_byod_guest_isolation.tf` |
| **Product** | ZIA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 4 |
| **Resource Types** | `zia_url_filtering_rules`, `zia_firewall_filtering_rule`, `zia_ssl_inspection_rules` |
| **Compliance** | -- |
| **Prerequisites** | Device groups for BYOD/Guest classification must be created or imported |

**What it does**: Restricts BYOD and guest devices to basic web browsing. Blocks cloud storage for BYOD devices, blocks high-risk URL categories for guest users, restricts BYOD to HTTP/HTTPS only (no FTP, SSH, etc.), and enforces SSL inspection on all untrusted devices.

**Resources created**:
- URL filtering rule: Block cloud storage for BYOD
- URL filtering rule: Block high-risk categories for guests
- Firewall rule: Restrict BYOD to HTTP-only protocols
- SSL inspection rule: Full decrypt on untrusted devices

**Customization points**:
- BYOD device group name
- Guest user group name
- Allowed categories for guest browsing
- SSL bypass list for BYOD (cert-pinned apps)

---

### ZIA-05: Incident Response / Threat Lockdown

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc05_threat_lockdown.tf` |
| **Product** | ZIA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 4 |
| **Resource Types** | `zia_url_filtering_rules`, `zia_firewall_filtering_rule`, `zia_ssl_inspection_rules` |
| **Compliance** | -- |
| **Prerequisites** | None |

**What it does**: Emergency policy set that blocks nearly everything except critical business services. Deploy during active security incidents to contain threats quickly. Blocks all web browsing except a small allow-list of critical services, blocks all outbound firewall traffic, and enables full SSL inspection with no bypasses.

**Resources created**:
- URL filtering rule: Block all web browsing
- URL filtering rule: Allow critical services only (M365, corporate domains)
- Firewall rule: Block all outbound non-HTTP traffic
- SSL inspection rule: Decrypt everything (no exceptions)

**Customization points**:
- Critical services allow-list
- Corporate domain exceptions
- Duration (designed to be temporary -- disable after incident)

---

### ZIA-06: DNS Security Enforcement

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc06_dns_security.tf` |
| **Product** | ZIA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 4 |
| **Resource Types** | `zia_firewall_filtering_rule`, `zia_url_filtering_rules`, `zia_firewall_dns_rule` |
| **Compliance** | -- |
| **Prerequisites** | None |

**What it does**: Blocks DNS tunneling, enforces DoH/DoT blocking, and detects DGA (Domain Generation Algorithm) domains. Creates firewall DNS rules for suspicious DNS patterns and TXT record monitoring with PCAP capture for forensic analysis. This is the **recommended first use case** because it is low-risk and requires no prerequisites.

**Resources created**:
- Firewall DNS rule: Block DNS tunneling patterns
- Firewall DNS rule: Monitor suspicious TXT records with PCAP
- URL filtering rule: Block DoH/DoT bypass services
- Firewall rule: Block non-standard DNS ports

**Customization points**:
- DNS tunneling detection thresholds
- DoH provider block list
- PCAP retention settings
- Alert notification recipients

---

### ZIA-07: Cloud DLP Enforcement

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc07_cloud_dlp.tf` |
| **Product** | ZIA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 5 |
| **Resource Types** | `zia_dlp_engines`, `zia_dlp_web_rules`, `zia_file_type_control_rules` |
| **Compliance** | HIPAA |
| **Prerequisites** | None |

**What it does**: Detects and blocks sensitive data uploads including SSN patterns, credit card numbers, and HIPAA-protected health information. Creates custom DLP engines with regex patterns for SSN and healthcare data identifiers, DLP web rules to block or monitor uploads to unauthorized destinations, and file type controls to prevent large file exfiltration.

**Resources created**:
- DLP engine: SSN pattern detection
- DLP engine: Healthcare data detection (HIPAA identifiers)
- DLP web rule: Block sensitive uploads to personal cloud storage
- DLP web rule: Monitor sensitive data to corporate SaaS (log only)
- File type control: Block large file uploads (exfiltration prevention)

**Customization points**:
- DLP regex patterns (SSN format, custom data identifiers)
- Upload size thresholds
- Monitored vs. blocked destinations
- Notification templates for DLP violations

---

### ZIA-08: SSL Deep Inspection

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc08_ssl_deep_inspection.tf` |
| **Product** | ZIA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 5 |
| **Resource Types** | `zia_url_categories`, `zia_ssl_inspection_rules` |
| **Compliance** | -- |
| **Prerequisites** | None |

**What it does**: Implements full SSL/TLS inspection with smart bypass lists for certificate-pinned applications. Creates a custom URL category for known cert-pinned services, bypass rules for privacy-sensitive sectors (finance, health, government), strict inspection rules for high-risk URL categories, and a decrypt-everything catch-all rule.

**Resources created**:
- Custom URL category: Cert-pinned services (Apple, Google updates, etc.)
- SSL rule: Bypass cert-pinned services
- SSL rule: Bypass Finance & Health categories (privacy)
- SSL rule: Strict inspection for high-risk categories
- SSL rule: Decrypt all remaining traffic (catch-all)

**Customization points**:
- Cert-pinned service list (add vendor-specific apps)
- Privacy bypass categories
- TLS minimum version enforcement
- Block action for expired/untrusted certificates

---

## ZIA Compliance Use Cases (5)

### ZIA-09: CMMC CUI Boundary Protection

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc09_cmmc_cui_boundary.tf` |
| **Product** | ZIA |
| **Category** | Compliance |
| **Difficulty** | Advanced |
| **Resources Created** | 10 |
| **Resource Types** | `zia_url_categories`, `zia_url_filtering_rules`, `zia_firewall_filtering_rule`, `zia_ssl_inspection_rules` |
| **Compliance** | CMMC, NIST 800-171, DFARS, ITAR |
| **Prerequisites** | None |

**What it does**: Implements NIST 800-171 controls SC 3.13.1/3.13.6/3.13.8/3.13.12/3.13.13 and DFARS 252.204-7012 requirements for protecting Controlled Unclassified Information (CUI) at system boundaries. Enforces default-deny posture by blocking unauthorized collaboration tools, untrusted downloads, adversary-nation destinations (China, Russia, Iran, North Korea), and mandates SSL inspection for all CUI-handling traffic.

**Resources created**:
- Custom URL category: Unauthorized collaboration tools
- Custom URL category: Adversary nation domains
- URL filtering rules: Block unauthorized collaboration, untrusted downloads
- URL filtering rules: Block adversary-nation browsing
- Firewall rules: Default-deny outbound for CUI segments
- Firewall rule: Allow only approved protocols
- SSL inspection rules: Mandatory inspection for CUI traffic

**Compliance mapping**:
- SC 3.13.1: Monitor, control, and protect communications at external boundaries
- SC 3.13.6: Deny by default, allow by exception
- SC 3.13.8: Implement cryptographic mechanisms to prevent unauthorized disclosure
- SC 3.13.12: Prohibit remote activation of collaborative computing devices
- SC 3.13.13: Control and monitor mobile code

---

### ZIA-10: CMMC Malware & System Integrity

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc10_cmmc_malware_integrity.tf` |
| **Product** | ZIA |
| **Category** | Compliance |
| **Difficulty** | Advanced |
| **Resources Created** | 9 |
| **Resource Types** | `zia_url_filtering_rules`, `zia_sandbox_rules`, `zia_firewall_dns_rule`, `zia_file_type_control_rules`, `zia_firewall_filtering_rule` |
| **Compliance** | CMMC, NIST 800-171 |
| **Prerequisites** | None |

**What it does**: Implements NIST 800-171 System Integrity controls SI 3.14.1 through 3.14.7. Provides advanced threat protection against malicious code using sandbox quarantine for unknown executables and documents, DNS security rules to detect C2 (Command and Control) callbacks, file type controls blocking dangerous upload and download categories, and firewall rules blocking known malicious IP ranges.

**Resources created**:
- URL filtering rules: Block known malware categories
- Sandbox rules: Quarantine first-time-seen executables and documents
- DNS rules: Block DGA patterns and known C2 domains
- File type control rules: Block dangerous file types (executables, scripts, archives)
- Firewall rules: Block outbound to known malicious IP ranges

**Compliance mapping**:
- SI 3.14.1: Flaw remediation (block known-bad patterns)
- SI 3.14.2: Malicious code protection
- SI 3.14.4: Update malicious code mechanisms
- SI 3.14.5: System monitoring
- SI 3.14.6/3.14.7: Security alerts and advisories

---

### ZIA-11: CMMC DLP for CUI / ITAR

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc11_cmmc_dlp_cui_itar.tf` |
| **Product** | ZIA |
| **Category** | Compliance |
| **Difficulty** | Advanced |
| **Resources Created** | 8 |
| **Resource Types** | `zia_dlp_engines`, `zia_dlp_notification_templates`, `zia_dlp_web_rules`, `zia_file_type_control_rules` |
| **Compliance** | CMMC, NIST 800-171, DFARS, ITAR |
| **Prerequisites** | None |

**What it does**: Controls CUI flow and prevents unauthorized export of ITAR technical data per NIST 800-171 AC 3.1.3, MP 3.8.7, SC 3.13.16, and DFARS 252.204-7012. Creates DLP engines that detect CUI markings (e.g., "CUI//SP-CTI", "CONTROLLED"), ITAR markers ("ITAR CONTROLLED", "USML Category"), and bulk PII patterns. Includes notification templates for compliance team alerts and file type controls for exfiltration prevention.

**Resources created**:
- DLP engine: CUI marking detection
- DLP engine: ITAR marker detection
- DLP engine: Bulk PII detection
- DLP notification template: Compliance team alert
- DLP web rule: Block CUI uploads to unauthorized destinations
- DLP web rule: Block ITAR data uploads anywhere external
- DLP web rule: Monitor bulk PII transfers
- File type control rule: Block large archive uploads

**Compliance mapping**:
- AC 3.1.3: Control CUI flow in accordance with approved authorizations
- MP 3.8.7: Control the use of removable media on system components
- SC 3.13.16: Protect the confidentiality of CUI at rest

---

### ZIA-12: CMMC Audit Logging & Incident Response

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc12_cmmc_audit_logging.tf` |
| **Product** | ZIA |
| **Category** | Compliance |
| **Difficulty** | Intermediate |
| **Resources Created** | 5 |
| **Resource Types** | `zia_firewall_filtering_rule`, `zia_firewall_dns_rule`, `zia_url_filtering_rules` |
| **Compliance** | CMMC, NIST 800-171, DFARS |
| **Prerequisites** | None |

**What it does**: Implements NIST 800-171 Audit (AU 3.3.1, 3.3.2) and Incident Response (IR 3.6.1, 3.6.2) controls, plus DFARS 72-hour cyber incident reporting requirements. Creates comprehensive firewall logging for all allowed and denied traffic, DNS query logging with PCAP capture for forensics, URL filtering with logging for sensitive categories, and blocking of suspicious downloads from newly registered domains.

**Resources created**:
- Firewall rule: Log all allowed traffic (audit trail)
- Firewall rule: Log all denied traffic (security events)
- DNS rule: Log all DNS queries with PCAP capture
- URL filtering rule: Log access to sensitive categories
- URL filtering rule: Block downloads from newly registered domains

**Compliance mapping**:
- AU 3.3.1: Create, protect, and retain system audit records
- AU 3.3.2: Ensure actions can be traced to individual users
- IR 3.6.1: Establish incident handling capability
- IR 3.6.2: Track, document, and report incidents

---

### ZIA-13: iOS Strict Enforcement

| Field | Value |
|-------|-------|
| **File** | `use-cases/zia/uc13_ios_strict_enforcement.tf` |
| **Product** | ZIA |
| **Category** | Standard |
| **Difficulty** | Advanced |
| **Resources Created** | 9 |
| **Resource Types** | `zia_ssl_inspection_rules`, `zia_url_categories`, `zia_forwarding_control_rule`, `zia_url_filtering_rules`, `zia_firewall_filtering_rule` |
| **Compliance** | -- |
| **Default State** | **ENABLED** |
| **Prerequisites** | iOS device group, iOS Supervised Mode (DEP/Apple Business Manager), ZCC strict enforcement toggle enabled |

**What it does**: Deploys ZIA-side policies required for strict enforcement on managed iOS devices. Creates SSL bypass rules for Apple certificate-pinned services (iCloud, App Store, Apple Push Notification service), IdP/SSO authentication bypass, forwarding control to force iOS traffic through Zscaler, URL filtering for Apple critical services, firewall rules for APNs connectivity, and risky category blocking specific to iOS.

**Resources created**:
- SSL inspection rules: Bypass Apple cert-pinned services
- SSL inspection rule: Bypass IdP/SSO authentication
- Custom URL category: Apple critical services
- Forwarding control rule: Force iOS traffic through Zscaler
- URL filtering rule: Allow Apple critical services
- Firewall rule: Allow APNs (port 5223)
- URL filtering rules: Block risky categories on iOS
- Firewall rules: iOS-specific protocol controls

**Customization points**:
- iOS device group name
- IdP domain list
- Apple service domains
- Risky category list for mobile

For a comprehensive guide to iOS strict enforcement including MDM deployment, tunnel modes, and troubleshooting, see the [iOS Strict Enforcement Guide](/blog/ios-enforcement/).

---

## ZPA Standard Use Cases (8)

### ZPA-01: Contractor Browser-Only Access

| Field | Value |
|-------|-------|
| **File** | `use-cases/zpa/uc01_contractor_browser_access.tf` |
| **Product** | ZPA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 3 |
| **Resource Types** | `zpa_segment_group`, `zpa_application_segment_browser_access`, `zpa_policy_access_rule` |
| **Compliance** | -- |
| **Prerequisites** | `var.zpa_default_server_group_id`, `var.zpa_access_policy_set_id` |

**What it does**: Provides clientless browser-based access for external contractors without requiring Zscaler Client Connector installation. Contractors access internal web applications through an isolated browser session. Includes a segment group for contractor apps, a browser access application segment with clientless app definitions, and an access policy restricting access to the contractor group.

**Resources created**:
- Segment group: Contractor Applications
- Browser access application segment: Contractor portal with clientless apps
- Access policy rule: Allow contractor group via browser access only

**Customization points**:
- Internal application URLs for contractor access
- Contractor user group (SAML attribute or SCIM group)
- Allowed application domains
- Session timeout duration

---

### ZPA-02: Privileged Remote Access (PRA)

| Field | Value |
|-------|-------|
| **File** | `use-cases/zpa/uc02_privileged_remote_access.tf` |
| **Product** | ZPA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 5 |
| **Resource Types** | `zpa_segment_group`, `zpa_application_segment`, `zpa_policy_access_rule`, `zpa_policy_timeout_rule` |
| **Compliance** | -- |
| **Prerequisites** | `var.zpa_default_server_group_id`, `var.zpa_access_policy_set_id` |

**What it does**: Secures RDP and SSH access for administrative tasks with enforced session recording and short timeouts. Creates separate application segments for RDP targets (port 3389) and SSH targets (port 22), an access policy restricted to the privileged admin group, and a short session timeout (30-minute max, 5-minute idle) that forces re-authentication.

**Resources created**:
- Segment group: Privileged Access
- Application segment: RDP targets (port 3389)
- Application segment: SSH targets (port 22)
- Access policy rule: Allow privileged admin group only
- Timeout policy rule: 5-minute idle, 30-minute max session

**Customization points**:
- Target server IPs/domains for RDP and SSH
- Privileged admin group name
- Session timeout values
- Session recording configuration (requires PRA license)

---

### ZPA-03: Department-Based Micro-Segmentation

| Field | Value |
|-------|-------|
| **File** | `use-cases/zpa/uc03_department_segmentation.tf` |
| **Product** | ZPA |
| **Category** | Standard |
| **Difficulty** | Advanced |
| **Resources Created** | 9 |
| **Resource Types** | `zpa_segment_group`, `zpa_application_segment`, `zpa_policy_access_rule` |
| **Compliance** | -- |
| **Prerequisites** | `var.zpa_default_server_group_id`, `var.zpa_access_policy_set_id`, SCIM groups or SAML attributes for departments |

**What it does**: Implements different application access levels per department or role. Engineering gets access to dev tools (Git, Jenkins, internal wikis), Finance gets ERP and accounting systems, HR gets HR management systems. Each department has its own segment group, application segments, and access policy -- ensuring least-privilege by role.

**Resources created**:
- Segment group: Engineering Applications
- Segment group: Finance Applications
- Segment group: HR Applications
- Application segments: Dev tools (Engineering)
- Application segments: ERP/accounting (Finance)
- Application segments: HR systems (HR)
- Access policy rules: One per department (3 total)

**Customization points**:
- Department names and SCIM group mappings
- Application targets per department
- Cross-department shared applications
- Port ranges per application type

---

### ZPA-04: Posture-Driven Zero Trust Access

| Field | Value |
|-------|-------|
| **File** | `use-cases/zpa/uc04_posture_zero_trust.tf` |
| **Product** | ZPA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 4 |
| **Resource Types** | `zpa_segment_group`, `zpa_application_segment`, `zpa_policy_access_rule` |
| **Compliance** | -- |
| **Prerequisites** | `var.zpa_default_server_group_id`, `var.zpa_access_policy_set_id`, `var.zpa_posture_profile_udid` (Certtest posture profile) |

**What it does**: Requires specific device posture checks before granting application access. Devices must pass antivirus validation, disk encryption verification, OS patch level checks, and firewall status. Creates a segment group for sensitive data applications, application segments for posture-gated resources, an allow rule that requires posture compliance, and an explicit deny rule for non-compliant devices.

**Resources created**:
- Segment group: Sensitive Data Applications
- Application segment: Posture-gated resources
- Access policy rule: Allow if posture compliant
- Access policy rule: Deny if posture non-compliant

**Customization points**:
- Posture profile UDID (link to your posture profile)
- Required posture checks (AV, encryption, OS version, firewall)
- Application targets requiring posture
- Grace period for non-compliant devices

---

### ZPA-05: Emergency Break-Glass Access

| Field | Value |
|-------|-------|
| **File** | `use-cases/zpa/uc05_emergency_break_glass.tf` |
| **Product** | ZPA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 4 |
| **Resource Types** | `zpa_segment_group`, `zpa_application_segment`, `zpa_policy_access_rule`, `zpa_policy_timeout_rule` |
| **Compliance** | -- |
| **Prerequisites** | `var.zpa_default_server_group_id`, `var.zpa_access_policy_set_id` |

**What it does**: Provides emergency full-access for incident response teams that bypasses normal restrictions. Creates a broad all-port TCP/UDP application segment covering all internal resources. The application segment is **disabled by default** and should only be enabled during active incidents. Includes the highest-priority access policy and a forced short session timeout (15-minute max).

**Resources created**:
- Segment group: Emergency Break-Glass
- Application segment: All internal resources (all ports, DISABLED by default)
- Access policy rule: Highest-priority allow for IR team
- Timeout policy rule: 15-minute max session

**Customization points**:
- Internal IP ranges for break-glass access
- Incident response team group name
- Session timeout duration
- Notification settings for break-glass activation

---

### ZPA-06: Application Discovery Mode

| Field | Value |
|-------|-------|
| **File** | `use-cases/zpa/uc06_app_discovery.tf` |
| **Product** | ZPA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 5 |
| **Resource Types** | `zpa_segment_group`, `zpa_application_segment`, `zpa_policy_access_rule` |
| **Compliance** | -- |
| **Prerequisites** | `var.zpa_default_server_group_id`, `var.zpa_access_policy_set_id` |

**What it does**: Uses broad wildcard application segments to discover what internal applications users are actually accessing. Essential for VPN-to-ZTNA migration planning. Creates three discovery segments: web apps (ports 80/443), infrastructure services (SSH/RDP/databases on ports 22/3389/1433/3306/5432), and custom ports (catch-all for non-standard services). A single broad access policy allows the pilot group to access everything while logging all connections.

**Resources created**:
- Segment group: Discovery Mode
- Application segment: Web app discovery (ports 80, 443)
- Application segment: Infrastructure discovery (SSH, RDP, DB ports)
- Application segment: Custom port discovery (all other ports)
- Access policy rule: Allow pilot group for discovery

**Customization points**:
- Internal IP/CIDR ranges to discover
- Pilot user group for discovery phase
- Port ranges per discovery tier
- Discovery duration (disable after migration planning)

---

### ZPA-07: Timeout Policy Enforcement

| Field | Value |
|-------|-------|
| **File** | `use-cases/zpa/uc07_timeout_enforcement.tf` |
| **Product** | ZPA |
| **Category** | Standard |
| **Difficulty** | Basic |
| **Resources Created** | 3 |
| **Resource Types** | `zpa_policy_timeout_rule` |
| **Compliance** | -- |
| **Prerequisites** | `var.zpa_access_policy_set_id`, Existing application segments referenced |

**What it does**: Implements different session timeout policies based on application sensitivity level. Standard apps get 10-minute idle / 24-hour max, sensitive apps get 5-minute idle / 1-hour max, and admin/PRA apps get 3-minute idle / 30-minute max. Tests timeout policies, re-authentication flows, and idle detection behavior.

**Resources created**:
- Timeout policy rule: Standard tier (10min idle / 24hr max)
- Timeout policy rule: Sensitive tier (5min idle / 1hr max)
- Timeout policy rule: Admin/PRA tier (3min idle / 30min max)

**Customization points**:
- Idle timeout values per tier
- Max session duration per tier
- Application segment assignments per tier
- Re-authentication behavior

---

### ZPA-08: Application Inspection & App Protection

| Field | Value |
|-------|-------|
| **File** | `use-cases/zpa/uc08_inspection_app_protection.tf` |
| **Product** | ZPA |
| **Category** | Standard |
| **Difficulty** | Intermediate |
| **Resources Created** | 4 |
| **Resource Types** | `zpa_segment_group`, `zpa_application_segment_inspection`, `zpa_policy_access_rule` |
| **Compliance** | OWASP |
| **Prerequisites** | `var.zpa_default_server_group_id`, `var.zpa_access_policy_set_id`, AppProtection profile configured |

**What it does**: Enables AppProtection (inline OWASP inspection) for web applications. Protects against SQL injection, cross-site scripting (XSS), command injection, and other OWASP Top 10 threats. Creates inspection-enabled application segments for a web app and an API, plus an access policy. An OWASP inspection policy rule is provided as a commented template.

**Resources created**:
- Segment group: Protected Web Applications
- Inspection application segment: Web app (HTTPS)
- Inspection application segment: API (HTTPS)
- Access policy rule: Allow with inspection enabled

**Customization points**:
- Web application URLs and ports
- API endpoint URLs
- AppProtection profile selection
- OWASP rule severity thresholds
- Custom inspection rules

---

## ZPA Compliance Use Cases (2)

### ZPA-09: CMMC Least Privilege & Posture-Gated CUI Access

| Field | Value |
|-------|-------|
| **File** | `use-cases/zpa/uc09_cmmc_least_privilege.tf` |
| **Product** | ZPA |
| **Category** | Compliance |
| **Difficulty** | Advanced |
| **Resources Created** | 10 |
| **Resource Types** | `zpa_segment_group`, `zpa_application_segment`, `zpa_policy_access_rule`, `zpa_policy_timeout_rule` |
| **Compliance** | CMMC, NIST 800-171 |
| **Prerequisites** | `var.zpa_default_server_group_id`, `var.zpa_access_policy_set_id`, `var.zpa_posture_profile_udid` |

**What it does**: Implements NIST 800-171 Access Control (AC 3.1.1/3.1.2/3.1.5/3.1.10/3.1.11/3.1.14) and Media Protection (MP 3.8.2/3.8.8) controls for least-privilege access to CUI. Creates per-application micro-segments for CUI document management, CUI database access, and CUI admin tools. All access requires device posture compliance. Includes explicit deny rules for non-compliant devices and strict session timeouts for CUI applications.

**Resources created**:
- Segment group: CUI Applications
- Application segment: CUI Document Management System
- Application segment: CUI Database
- Application segment: CUI Admin Tools
- Access policy rule: Allow CUI Docs (posture + group required)
- Access policy rule: Allow CUI Database (posture + group required)
- Access policy rule: Allow CUI Admin (posture + elevated group)
- Access policy rule: Deny non-compliant devices
- Timeout policy rule: CUI apps (5min idle / 1hr max)
- Timeout policy rule: CUI admin (3min idle / 30min max)

**Compliance mapping**:
- AC 3.1.1: Limit system access to authorized users
- AC 3.1.2: Limit system access to authorized functions
- AC 3.1.5: Employ the principle of least privilege
- AC 3.1.10: Use session lock with pattern-hiding displays
- AC 3.1.11: Terminate user sessions after defined conditions
- AC 3.1.14: Route remote access via managed access control points
- MP 3.8.2: Limit access to CUI on system media
- MP 3.8.8: Prohibit portable storage without identifiable owner

---

### ZPA-10: EO 14028 / CISA ZTMM Zero Trust Architecture

| Field | Value |
|-------|-------|
| **File** | `use-cases/zpa/uc10_eo14028_zero_trust.tf` |
| **Product** | ZPA |
| **Category** | Compliance |
| **Difficulty** | Advanced |
| **Resources Created** | 14 |
| **Resource Types** | `zpa_segment_group`, `zpa_application_segment`, `zpa_policy_access_rule`, `zpa_policy_forwarding_rule`, `zpa_policy_timeout_rule` |
| **Compliance** | EO-14028, CISA-ZTMM |
| **Prerequisites** | `var.zpa_default_server_group_id`, `var.zpa_access_policy_set_id`, `var.zpa_posture_profile_udid` |

**What it does**: Implements Executive Order 14028 and CISA Zero Trust Maturity Model v2.0 across all 5 pillars (Identity, Devices, Networks, Applications, Data). Creates a three-tier architecture:
- **Tier 1**: Public-facing internal apps (basic auth, standard timeout)
- **Tier 2**: Restricted apps with device posture gates (enhanced auth, shorter timeout)
- **Tier 3**: Critical infrastructure with strictest controls (MFA + posture + network restrictions, shortest timeout)

Includes per-application micro-segments, device posture gates, default-deny with explicit allow, forwarding policy to prevent lateral movement, and tiered session timeouts.

**Resources created**:
- Segment groups: Tier 1, Tier 2, Tier 3
- Application segments: 2 per tier (6 total)
- Access policy rules: Tier-specific allow rules (3)
- Access policy rule: Default deny
- Forwarding policy rule: Prevent lateral movement
- Timeout policy rules: Tier-specific timeouts (3)

**Compliance mapping**:
- EO 14028 Section 3: Modernizing Federal Cybersecurity (Zero Trust Architecture)
- CISA ZTMM Pillar 1 - Identity: Continuous validation
- CISA ZTMM Pillar 2 - Devices: Posture assessment
- CISA ZTMM Pillar 3 - Networks: Micro-segmentation
- CISA ZTMM Pillar 4 - Applications: Per-app access control
- CISA ZTMM Pillar 5 - Data: Data-centric protection

---

## Quick Reference Table

| ID | Name | Product | Category | Difficulty | Resources | Compliance |
|----|------|---------|----------|------------|-----------|------------|
| ZIA-01 | Geo-Based Access Control | ZIA | Standard | Basic | 3 | -- |
| ZIA-02 | SaaS Application Control | ZIA | Standard | Intermediate | 4 | -- |
| ZIA-03 | Time-Based Browsing Control | ZIA | Standard | Intermediate | 3 | -- |
| ZIA-04 | BYOD / Guest Network Isolation | ZIA | Standard | Intermediate | 4 | -- |
| ZIA-05 | Incident Response / Threat Lockdown | ZIA | Standard | Intermediate | 4 | -- |
| ZIA-06 | DNS Security Enforcement | ZIA | Standard | Intermediate | 4 | -- |
| ZIA-07 | Cloud DLP Enforcement | ZIA | Standard | Intermediate | 5 | HIPAA |
| ZIA-08 | SSL Deep Inspection | ZIA | Standard | Intermediate | 5 | -- |
| ZIA-09 | CMMC CUI Boundary Protection | ZIA | Compliance | Advanced | 10 | CMMC, NIST, DFARS, ITAR |
| ZIA-10 | CMMC Malware & System Integrity | ZIA | Compliance | Advanced | 9 | CMMC, NIST |
| ZIA-11 | CMMC DLP for CUI / ITAR | ZIA | Compliance | Advanced | 8 | CMMC, NIST, DFARS, ITAR |
| ZIA-12 | CMMC Audit Logging & IR | ZIA | Compliance | Intermediate | 5 | CMMC, NIST, DFARS |
| ZIA-13 | iOS Strict Enforcement | ZIA | Standard | Advanced | 9 | -- |
| ZPA-01 | Contractor Browser-Only Access | ZPA | Standard | Intermediate | 3 | -- |
| ZPA-02 | Privileged Remote Access (PRA) | ZPA | Standard | Intermediate | 5 | -- |
| ZPA-03 | Department Micro-Segmentation | ZPA | Standard | Advanced | 9 | -- |
| ZPA-04 | Posture-Driven Zero Trust | ZPA | Standard | Intermediate | 4 | -- |
| ZPA-05 | Emergency Break-Glass Access | ZPA | Standard | Intermediate | 4 | -- |
| ZPA-06 | Application Discovery Mode | ZPA | Standard | Intermediate | 5 | -- |
| ZPA-07 | Timeout Policy Enforcement | ZPA | Standard | Basic | 3 | -- |
| ZPA-08 | App Inspection & Protection | ZPA | Standard | Intermediate | 4 | OWASP |
| ZPA-09 | CMMC Least Privilege CUI | ZPA | Compliance | Advanced | 10 | CMMC, NIST |
| ZPA-10 | EO 14028 / CISA ZTMM | ZPA | Compliance | Advanced | 14 | EO-14028, CISA-ZTMM |
