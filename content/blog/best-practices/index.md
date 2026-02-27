---
title: "Zscaler Terraform Best Practices"
date: 2026-02-27
draft: false
description: "Comprehensive best practices for deploying Zscaler ZIA, ZPA, ZCC, and ZDX using Terraform and the Deploy Kit."
summary: "Best practices for Zscaler deployments organized by product -- covering ZIA traffic forwarding, URL filtering, SSL inspection, ZPA app segmentation, ZCC rollout strategy, ZDX monitoring, and operational guidelines for Terraform-based infrastructure management."
tags: ["best-practices", "terraform", "zia", "zpa"]
categories: ["Technical"]
showTableOfContents: true
---

These recommendations are based on official Zscaler guidance, field experience from a live production tenant, and common deployment patterns encountered during real-world implementations. Whether you are deploying your first use case or managing an enterprise-scale Zscaler environment, these practices will help you avoid common pitfalls and build a resilient security architecture.

---

## ZIA (Zscaler Internet Access)

### Traffic Forwarding

- **Forward ALL internet-bound traffic** (all protocols, all ports) to Zscaler -- not just HTTP/HTTPS.
- Use **GRE or IPsec tunnels** for branch offices and data centers.
- Deploy **Zscaler Client Connector (ZCC)** for remote and roaming users.
- Combine **PAC files with ZCC** for hybrid environments where some traffic must bypass the tunnel.
- Use **forwarding control rules** to route specific traffic (e.g., ZPA-bound) appropriately.
- Avoid split tunneling wherever possible -- full tunnel provides complete visibility.

### URL Filtering

- Start with **global block rules** for universally high-risk categories:
  - Malware, Phishing, Spyware, Botnets, Anonymizers
- Layer **specific allow/block rules** per user group, department, or location.
- Block unwanted traffic **above** any default allow rule -- policy order matters.
- Use **CAUTION** action for shadow IT categories to educate users without blocking.
- Always block:
  - **Newly Registered Domains (NRODs)** -- top malware delivery vector
  - **Miscellaneous/Uncategorized** -- unknown sites are untrusted by default
  - **Advanced Security Risk** categories

### SSL Inspection

- **Decrypt by default**, bypass only where strictly necessary.
- Mandatory bypass list (certificate-pinned or legally required):
  - Health and Medicine categories (HIPAA)
  - Financial Services categories (PCI)
  - Government categories
  - Certificate-pinned services (Apple, Google updates, some banking apps)
- Enforce **TLS 1.2 minimum** for both client and server connections.
- Block connections with expired, self-signed, or untrusted certificates.
- Keep SSL rule names under **31 characters** (API limitation).

### Advanced Threat Protection (ATP)

- Block: DGA domains, SSH tunneling, C2 traffic, Tor, P2P protocols.
- Enable alerts for unknown/suspicious C2 traffic patterns.
- Set risk tolerance to **20-35 range** (lower = more aggressive blocking).
- Enable **ML-based sandbox action** for zero-day detection.
- **Quarantine** first-time-seen executables and documents (do not just alert).

### Firewall Policy

- Move toward a **default-deny** posture over time.
- Explicitly allow only required ports: 80, 443, 53 (and application-specific ports).
- Block all outbound traffic to known malicious IP ranges.
- Log both allowed AND denied traffic for audit trails.
- Use **PCAP capture** on DNS rules for forensic analysis.

### Policy Processing Order

ZIA evaluates policies in a specific order. Design your rules with this flow in mind:

```
1. Browser Control Policy
2. FTP Control Policy
3. URL Filtering Policy
4. SSL Inspection Policy
5. Advanced Malware Protection (Sandbox)
6. Advanced Threat Protection (ATP)
7. File Type Control Policy
8. Bandwidth Control Policy
9. Data Loss Prevention (DLP)
10. Cloud Firewall Policy
```

**Key implication**: SSL inspection (step 4) must decrypt traffic before DLP (step 9) or ATP (step 6) can inspect it. If SSL bypasses a connection, downstream policies cannot see the content.

---

## ZPA (Zscaler Private Access)

### App Connectors

- Deploy with **N+1 redundancy** minimum -- always at least 2 connectors per connector group.
- Each connector supports approximately **500 Mbps** throughput; scale connector count for bandwidth.
- Place connectors **close to the applications** they serve (same LAN/VLAN).
- Use **dedicated connector groups** for different purposes:
  - Application serving
  - Log streaming (LSS)
  - Machine tunnels
- Monitor connector health via ZPA Admin Portal and ZDX.
- For Docker connectors, ensure **NET_ADMIN** capability is granted.
- Use unique provisioning keys per connector (not shared keys).

### Application Segmentation

- Define **narrow scopes** -- specific domains, IPs, and ports rather than broad CIDRs.
- Never use `0.0.0.0/0` or `*` in production application segments.
- Group related applications into **segment groups** for organizational clarity.
- Use **Server Groups** to map connectors to application locations.
- Separate application segments by sensitivity level (public, internal, restricted, critical).
- Use **wildcard domains** only during discovery phase, then narrow down.

### Access Policies

- Apply **least-privilege** access -- users get access only to what they need.
- Use **SAML attributes** for SSO integration and group-based access.
- Use **SCIM** for automated user/group synchronization from IdP.
- Create **explicit deny rules** at the bottom of the policy -- do not rely on implicit deny.
- Layer conditions: identity + device posture + time + network for strongest Zero Trust.
- Review and audit access policies quarterly.

### Session Management

- Implement **tiered session timeouts** based on application sensitivity:
  - Standard apps: 10-minute idle / 24-hour max
  - Sensitive apps: 5-minute idle / 1-hour max
  - Admin/privileged: 3-minute idle / 30-minute max
- Force re-authentication for critical applications.
- Use **forwarding policy rules** to prevent lateral movement between segments.

---

## ZCC (Zscaler Client Connector)

### Phased Rollout

Deploy ZCC in waves to minimize risk and gather feedback:

| Phase | Users | Duration | Purpose |
|-------|-------|----------|---------|
| 1 - IT Pilot | 25-50 (IT staff) | 1-2 weeks | Validate functionality, find issues |
| 2 - Expanded IT | 100-150 (IT + power users) | 1-2 weeks | Broader testing, app compatibility |
| 3 - Early Adopters | 200-300 (willing departments) | 1-2 weeks | Real-world validation |
| 4 - Full Deployment | Batches of 1,000 | Rolling | Organization-wide rollout |

### Configuration

- Use **Tunnel with Local Proxy** mode for environments with existing VPN solutions.
- Enable **Z-Tunnel 2.0 with DTLS** for:
  - VoIP and real-time applications (Zoom, Teams)
  - Latency-sensitive workloads
  - Better throughput on high-latency connections
- Configure **Trusted Network Detection** to bypass Zscaler tunneling on corporate LAN.
- Allowlist ZCC processes in endpoint AV/firewall/EDR products.
- Deploy via MDM (Intune, JAMF, SCCM) for managed devices.

### iOS Strict Enforcement

For managed iOS devices:
- Requires **iOS Supervised Mode** (Apple Business Manager / DEP)
- Enable strict enforcement toggle in ZCC Admin Portal
- Deploy ZIA-side policies for Apple cert-pinned service bypass (UC-13)
- Test on a small group of devices first
- Monitor ZCC status via ZDX

For the complete iOS guide, see [iOS Strict Enforcement: The Complete Guide](/blog/ios-enforcement/).

---

## ZDX (Zscaler Digital Experience)

### Rollout

- Start with a **pilot group** (Tier 3 Helpdesk or IT) to baseline metrics.
- Expand monitoring in batches of up to **5,000 users** per wave.
- Allow 1-2 weeks per wave for baseline establishment.

### Application Monitoring

Prioritize monitoring in this order:

| Priority | Application Type | Examples |
|----------|-----------------|----------|
| 1 - Critical | Core business apps | M365, Zoom, Salesforce, SAP |
| 2 - Department | Team-specific tools | Jira (Engineering), Workday (HR) |
| 3 - Noisy | High-ticket generators | VPN, legacy apps, custom portals |

### Probes

- Limit to **30 probes per user** to avoid overwhelming endpoints.
- Configure probe intervals based on criticality:
  - Critical apps: Every 5 minutes
  - Standard apps: Every 15 minutes
  - Low priority: Every 30 minutes
- Avoid probing internal services that cannot handle the additional load.

### Alerting

- Integrate with **ITSM tools** (ServiceNow, PagerDuty, Slack).
- Use **alert throttling** to reduce noise (no more than 1 alert per app per hour).
- Set meaningful thresholds based on baseline data, not arbitrary values.
- Create separate alert profiles for different teams (NOC vs. Helpdesk vs. Management).

---

## SSL Inspection Strategy

SSL inspection is the foundation of all content-based policies. Without decryption, DLP, ATP, sandbox, and URL filtering cannot inspect encrypted traffic.

### What to Inspect (Decrypt)

- **Everything by default** -- start with a decrypt-all rule.
- High-risk categories: Newly Registered Domains, Uncategorized, Anonymizers.
- Cloud storage uploads (for DLP inspection).
- Social media (for data exfiltration prevention).

### What to Bypass (Do Not Decrypt)

- **Health & Medicine** categories (HIPAA/privacy regulations)
- **Financial Services** categories (PCI compliance)
- **Government** categories
- **Certificate-pinned applications**:
  - Apple services (iCloud, App Store, Apple Push)
  - Windows Update
  - Google Chrome updates
  - Banking and financial apps
  - Medical device communications
- **Identity Provider traffic** (SAML/SSO flows)

### Rule Design

```
Order 1: Bypass cert-pinned services     (custom URL category)
Order 2: Bypass Health & Finance          (predefined categories)
Order 3: Bypass IdP/SSO traffic          (custom URL category)
Order 4: Strict inspect high-risk        (Malware, NRODs, Uncategorized)
Order 5: Decrypt everything else         (catch-all)
```

---

## URL Filtering Strategy

### Recommended Blocks (All Environments)

These categories should be blocked in every deployment:

| Category | Risk | Reason |
|----------|------|--------|
| Advanced Security Risk | Critical | Known threat infrastructure |
| Newly Registered Domains | Critical | #1 malware delivery vector |
| Miscellaneous / Uncategorized | High | Unknown = untrusted |
| Anonymizers / Proxies | High | Policy bypass attempts |
| Malware / Spyware / Phishing | Critical | Direct threats |
| Botnets / C2 | Critical | Active compromises |
| P2P File Sharing | High | Data exfiltration, malware |
| Cryptomining | Medium | Resource abuse |

### Recommended Cautions

These categories should show a warning page:

| Category | Reason |
|----------|--------|
| Streaming Media | Bandwidth management |
| Social Networking (during work) | Productivity |
| Personal Cloud Storage | Shadow IT visibility |
| Webmail | Data leak risk |

---

## Firewall Policy Order

Design your ZIA Cloud Firewall rules in this order:

```
1. Allow critical infrastructure    (DNS to Zscaler, NTP, DHCP)
2. Allow explicitly approved ports  (80, 443 to specific destinations)
3. Block known-bad destinations     (Threat intel, sanctioned countries)
4. Block risky protocols            (IRC, Telnet, raw SMTP)
5. Log and allow remaining          (Catch-all with full logging)
6. Default deny                     (Block everything else)
```

---

## Operational Best Practices

### Version Control

- Keep all Terraform files in Git.
- Use branches for proposed changes, merge to main after review.
- Never commit `.env` files or `terraform.tfstate` (both are in `.gitignore`).
- Tag releases when deploying to production.

### Change Management

- Always run `terraform plan` before `terraform apply`.
- Review the plan output carefully -- check for unexpected destroys.
- Deploy use cases in DISABLED state first, then enable after review.
- Keep a rollback plan: `terraform destroy -target=<resource>` for individual use cases.

### Monitoring

- Check ZIA Admin Portal for activation status after each deploy.
- Monitor ZDX for user experience impact after policy changes.
- Review ZIA/ZPA logs for unexpected blocks after enabling new rules.
- Set up alerts for policy violation spikes.

### Documentation

- Document every deployed use case and its business justification.
- Maintain a mapping of Terraform resources to business requirements.
- Keep compliance evidence (screenshots, exports) for audit purposes.
- Update use case customizations in comments within the `.tf` files.
