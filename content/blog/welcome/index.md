---
title: "Introducing Zscaler Deploy Kit"
date: 2026-02-27
draft: false
description: "An open-source Infrastructure-as-Code toolkit that turns Zscaler Zero Trust deployments from weeks of manual work into repeatable, auditable Terraform configurations."
summary: "Zscaler Deploy Kit is a battle-tested IaC toolkit with 23 pre-built use cases, a guided TUI, and AI-agent integration. It was built from a live production tenant to solve the real complexity of Zscaler Zero Trust deployments."
tags: ["announcement", "zero-trust", "terraform"]
categories: ["Announcements"]
series: ["Zscaler Deploy Kit"]
showTableOfContents: true
---

## The Problem: Zscaler is Powerful, But Complex

Zscaler's Zero Trust Exchange is one of the most comprehensive security platforms available today. Between ZIA (Internet Access), ZPA (Private Access), and ZDX (Digital Experience), organizations gain full-stack protection covering web security, private application access, DLP, advanced threat protection, SSL inspection, and compliance enforcement.

But that power comes at a cost: complexity.

A typical Zscaler deployment involves hundreds of configuration objects -- URL filtering rules, firewall policies, SSL inspection rules, application segments, access policies, DLP engines, forwarding profiles, and more. Each object has its own schema, its own API quirks, and its own interactions with the rest of the stack. Most organizations spend weeks or months clicking through the Admin Portal, building configurations by hand, with no version control, no repeatability, and no audit trail.

For organizations pursuing CMMC Level 2, NIST 800-171, or other compliance frameworks, the challenge multiplies. Auditors want evidence of consistent configuration. They want to see that controls are documented, repeatable, and testable. Manual portal configurations fail that test.

## The Solution: 23 Battle-Tested Terraform Configurations

Zscaler Deploy Kit is an open-source Infrastructure-as-Code toolkit that solves this problem. It packages 23 pre-built use cases -- covering everything from geo-based access control and SaaS application management to full CMMC CUI boundary protection and Executive Order 14028 Zero Trust Architecture -- into self-contained Terraform configurations that deploy against your Zscaler tenant in minutes.

These are not theoretical templates. Every configuration was built, tested, and validated against a live Zscaler production tenant. The base modules were exported using Zscaler Terraformer, giving you a reference implementation grounded in reality rather than documentation.

Every use case deploys in a **DISABLED** state by default, so you can review what was created in the Admin Portal before enabling anything. This is a safety-first design: deploy, inspect, then activate.

## Three Ways to Use It

The Deploy Kit meets teams where they are:

**The TUI (Terminal User Interface)** provides a guided, interactive experience for teams that want to deploy without writing Terraform. Built with Python Textual, it walks users through credential setup, use case browsing, and one-click deployment with plan-and-confirm gates at every step. If your security team is not comfortable with Terraform CLI, the TUI gives them a safe path forward.

**Direct Terraform CLI** is available for infrastructure engineers who want full control. Each use case is a standalone `.tf` file that can be reviewed, customized, and deployed with standard `terraform plan` and `terraform apply` workflows. Version control, pull requests, and code review integrate naturally.

**AI-Agent Integration** works alongside the Zscaler MCP Server for developer workflows. AI coding assistants like Claude can use the Deploy Kit for bulk infrastructure deployment while using the MCP Server for real-time queries and single-resource operations. Both share the same OneAPI OAuth2 credentials.

## Built for Compliance

Seven of the 23 use cases are purpose-built for compliance:

- **ZIA UC09-UC12**: CMMC Level 2 / NIST 800-171 controls covering CUI boundary protection, malware integrity, DLP for CUI and ITAR data, and audit logging with incident response
- **ZPA UC09**: CMMC least-privilege access with posture-gated CUI application micro-segments
- **ZPA UC10**: Executive Order 14028 / CISA Zero Trust Maturity Model implementation across all five pillars

Infrastructure-as-Code is not just a convenience for compliance -- it is a requirement. When your security configuration is defined in code, you get auditability, repeatability, drift detection, and version history. Every change is tracked, every deployment is reproducible, and every control can be tested.

## What is Next

This blog will serve as the home for guides, tutorials, and deep dives into Zscaler Zero Trust deployment. Start with the [Getting Started guide](/blog/getting-started/) to go from zero to your first deployment, or browse the [complete use case reference](/blog/use-case-guide/) to see what is available.

**Author: LJ / L&L DarkSkies**
