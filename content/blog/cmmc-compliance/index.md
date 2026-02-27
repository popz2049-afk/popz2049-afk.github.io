---
title: "CMMC Level 2 Compliance with Zscaler: Automated with Terraform"
date: 2026-02-27
draft: false
description: "How the Deploy Kit's 7 compliance use cases map to CMMC Level 2 and NIST 800-171 controls, and why Infrastructure-as-Code matters for compliance."
summary: "The Zscaler Deploy Kit includes 7 compliance-focused use cases that directly implement CMMC Level 2 / NIST 800-171 controls. This post maps each use case to specific control families and explains why Terraform-based compliance is more auditable, repeatable, and defensible than manual configuration."
tags: ["cmmc", "nist-800-171", "compliance", "dfars", "cui"]
categories: ["Compliance"]
series: ["Zscaler Deploy Kit"]
showTableOfContents: true
---

## The Compliance Challenge for Defense Contractors

Organizations handling Controlled Unclassified Information (CUI) under DFARS 252.204-7012 must implement the 110 security controls defined in NIST 800-171. With CMMC 2.0 now requiring third-party assessments for Level 2 certification, the bar is higher than ever: you need to not only implement the controls, but prove they are consistently applied, documented, and testable.

The traditional approach -- manually configuring security policies through web portals -- fails the compliance test in three critical ways. First, there is no audit trail. When an assessor asks "when was this policy created and by whom?", clicking through a portal leaves no traceable history. Second, there is no repeatability. If you need to rebuild your security stack in a disaster recovery scenario, manual configurations must be recreated from memory or screenshots. Third, there is no drift detection. Policies changed through the portal after the assessment leave no record, and there is no mechanism to detect or alert on unauthorized modifications.

Infrastructure-as-Code solves all three problems. When your security controls are defined in Terraform, every change is versioned in Git, every deployment is reproducible, and any drift from the defined state can be detected with `terraform plan`.

## The 7 Compliance Use Cases

The Zscaler Deploy Kit includes 7 purpose-built compliance use cases -- 5 for ZIA and 2 for ZPA -- that directly implement NIST 800-171 controls across multiple control families.

### ZIA Compliance Use Cases

**UC09: CMMC CUI Boundary Protection** creates 10 resources implementing System and Communications Protection controls (SC 3.13.1, 3.13.6, 3.13.8, 3.13.12, 3.13.13). It enforces a default-deny posture at the network boundary, blocks adversary-nation destinations, prevents unauthorized collaboration tools from accessing CUI environments, and mandates SSL inspection for all CUI-handling traffic. This is the foundation of your CUI boundary -- the control that ensures data does not leak to unauthorized destinations.

**UC10: CMMC Malware and System Integrity** deploys 9 resources covering System Integrity controls (SI 3.14.1 through 3.14.7). It implements sandbox quarantine for unknown executables, DNS-based detection of C2 callbacks and domain generation algorithms, file type controls blocking dangerous download categories, and firewall rules blocking known malicious IP ranges. This is your automated malicious code protection -- a core CMMC requirement.

**UC11: CMMC DLP for CUI / ITAR** creates 8 resources addressing Access Control (AC 3.1.3), Media Protection (MP 3.8.7), and System and Communications Protection (SC 3.13.16). It deploys DLP engines that detect CUI markings, ITAR technical data markers, and bulk PII patterns. Any attempt to upload CUI or ITAR data to unauthorized destinations is blocked, logged, and the compliance team is alerted via notification templates.

**UC12: CMMC Audit Logging and Incident Response** provides 5 resources for Audit (AU 3.3.1, 3.3.2) and Incident Response (IR 3.6.1, 3.6.2) controls, plus DFARS 72-hour cyber incident reporting support. It creates comprehensive logging for all allowed and denied traffic, DNS query logging with PCAP capture for forensics, and blocks suspicious downloads from newly registered domains.

**UC13: iOS Strict Enforcement** (while categorized as standard, not compliance) is often required for CMMC environments where mobile devices access CUI. It ensures 100% traffic inspection on managed iOS devices with no bypass capability.

### ZPA Compliance Use Cases

**UC09: CMMC Least Privilege and Posture-Gated CUI Access** creates 10 resources implementing Access Control (AC 3.1.1, 3.1.2, 3.1.5, 3.1.10, 3.1.11, 3.1.14) and Media Protection (MP 3.8.2, 3.8.8). It deploys per-application micro-segments for CUI document management, CUI databases, and CUI admin tools. Every access request requires both group membership and device posture compliance. Non-compliant devices are explicitly denied. Session timeouts enforce re-authentication for CUI applications.

**UC10: EO 14028 / CISA ZTMM Zero Trust Architecture** deploys 14 resources implementing a three-tier Zero Trust architecture aligned with all 5 pillars of the CISA Zero Trust Maturity Model. While designed for Executive Order 14028 compliance, the controls overlap significantly with CMMC -- particularly around identity verification, device posture, micro-segmentation, and per-application access control.

## NIST 800-171 Control Family Coverage

Across all 7 use cases, the Deploy Kit covers controls in these NIST 800-171 families:

| Control Family | Controls Addressed | Use Cases |
|---------------|-------------------|-----------|
| Access Control (AC) | 3.1.1, 3.1.2, 3.1.3, 3.1.5, 3.1.10, 3.1.11, 3.1.14 | ZPA-UC09, ZIA-UC11 |
| Audit & Accountability (AU) | 3.3.1, 3.3.2 | ZIA-UC12 |
| Incident Response (IR) | 3.6.1, 3.6.2 | ZIA-UC12 |
| Media Protection (MP) | 3.8.2, 3.8.7, 3.8.8 | ZPA-UC09, ZIA-UC11 |
| System & Communications Protection (SC) | 3.13.1, 3.13.6, 3.13.8, 3.13.12, 3.13.13, 3.13.16 | ZIA-UC09, ZIA-UC11 |
| System & Information Integrity (SI) | 3.14.1, 3.14.2, 3.14.4, 3.14.5, 3.14.6, 3.14.7 | ZIA-UC10 |

## Why IaC Matters for Compliance

When an assessor reviews your CMMC implementation, they look for three things: that controls are implemented, that they are documented, and that they are consistently maintained. Terraform delivers on all three.

**Auditability**: Every Terraform file is a human-readable record of what controls are in place. The Git history shows when each control was implemented, who approved it, and what changed over time. This is orders of magnitude more useful than portal screenshots.

**Repeatability**: If you need to stand up a new enclave, replicate controls to a second tenant, or rebuild after an incident, `terraform apply` reproduces the exact configuration. No tribal knowledge required.

**Drift Detection**: Running `terraform plan` against your live tenant immediately reveals any configuration that has drifted from the defined state. This catches unauthorized changes -- whether from a well-meaning admin clicking through the portal or a compromised account modifying policies.

**Evidence Generation**: The Terraform plan output, apply logs, and state files serve as compliance evidence. They prove that the controls described in your System Security Plan are actually deployed and match the documented configuration.

## Getting Started with Compliance Use Cases

The recommended deployment order for a CMMC-focused environment:

1. **ZIA-UC09** (CUI Boundary Protection) -- Establish the default-deny boundary first
2. **ZIA-UC10** (Malware and System Integrity) -- Layer on threat protection
3. **ZIA-UC11** (DLP for CUI/ITAR) -- Prevent data exfiltration
4. **ZIA-UC12** (Audit Logging) -- Enable comprehensive logging
5. **ZPA-UC09** (Least Privilege CUI Access) -- Implement per-application access control
6. **ZPA-UC10** (Zero Trust Architecture) -- Complete the Zero Trust posture

All use cases deploy in a DISABLED state (except UC13), allowing you to review every resource in the Admin Portal before activation. See the [Getting Started guide](/blog/getting-started/) for the full deployment workflow.
