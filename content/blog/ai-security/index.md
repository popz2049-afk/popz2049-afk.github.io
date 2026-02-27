---
title: "Securing Enterprise AI: Zscaler's SPLX Acquisition and AI Security Suite"
date: 2026-02-27
draft: false
description: "How Zscaler's SPLX acquisition and AI Security Suite address shadow AI, GenAI data leakage, and enterprise AI governance -- and what you can automate with Terraform."
summary: "Zscaler acquired SplxAI in November 2025 and launched the AI Security Suite in January 2026, delivering shadow AI detection, GenAI app control, and inline prompt DLP. This post covers the three pillars of AI security, what is automatable via Terraform, and how the Deploy Kit's UC14 use case implements GenAI control policies."
tags: ["ai-security", "genai", "dlp", "shadow-ai", "splx"]
categories: ["Deep Dives"]
series: ["Zscaler Deploy Kit"]
showTableOfContents: true
---

## The Enterprise AI Security Problem

Every organization is now an AI organization, whether it planned to be or not. Employees are using ChatGPT, Microsoft Copilot, Google Gemini, and dozens of niche AI tools to write code, summarize documents, draft emails, and analyze data. Most of this usage is invisible to security teams. When an engineer pastes proprietary source code into ChatGPT or a financial analyst uploads a confidential spreadsheet to a third-party AI summarizer, the data leaves the organization's control boundary permanently.

This is not a theoretical risk. Shadow AI -- unauthorized use of generative AI tools -- is the fastest-growing data leakage vector in the enterprise. Traditional DLP was not designed for conversational interfaces where sensitive data is submitted as natural language prompts rather than file uploads.

## The SPLX Acquisition and AI Security Suite

Zscaler addressed this gap through acquisition and product development in rapid succession. On November 3, 2025, Zscaler acquired **SplxAI**, a startup specializing in AI application security testing and red teaming. SPLX brought automated attack simulation capabilities -- over 5,000 AI-specific attack patterns covering prompt injection, jailbreaking, data extraction, and model manipulation.

Two months later, on January 27, 2026, Zscaler launched the **AI Security Suite** built on three pillars:

**AI Asset Management** provides visibility into all AI tools and services in use across the organization. It discovers shadow AI usage by analyzing traffic patterns, identifying which employees are using which AI services, and classifying the sensitivity of data being shared with those services.

**Secure Access to AI** enforces granular policies on how employees interact with generative AI tools. This includes allowing ChatGPT for general queries while blocking file uploads, permitting Microsoft Copilot for licensed users while isolating it for others, and applying inline DLP to AI prompts to prevent sensitive data from being submitted.

**Secure AI Infrastructure** protects organizations that build and deploy their own AI applications. This is where SPLX's capabilities are most visible -- automated red teaming of internal LLMs, MCP Gateway for securing agent-to-agent communications, and runtime protection for AI model endpoints.

## WebSocket Inspection for Copilot

A technical detail worth highlighting: Microsoft Copilot and several other AI assistants use **WebSocket connections** rather than standard HTTP requests for their conversational interfaces. Traditional SSL inspection that operates on HTTP request/response pairs cannot inspect WebSocket traffic. Zscaler's AI Security Suite includes dedicated WebSocket inspection that decodes the bidirectional message stream, applies DLP classification to each prompt and response, and enforces policy inline. Without this capability, Copilot traffic passes through the security stack uninspected.

## What You Can Automate with Terraform

While the AI Security Suite's advanced features (shadow AI discovery, AI asset management, SPLX red teaming) are managed through the Zscaler Admin Portal, the core GenAI app control policies are fully automatable through existing ZIA Terraform resources.

The key resource is `zia_cloud_app_control_rule` with `type = "AI_ML"`. This allows you to define rules that allow, block, caution, or isolate specific AI applications:

```hcl
resource "zia_cloud_app_control_rule" "block_chatgpt_uploads" {
  name        = "UC14-Block-ChatGPT-File-Uploads"
  description = "Block file uploads to ChatGPT while allowing general usage"
  type        = "AI_ML"
  state       = "DISABLED"
  applications = ["CHATGPT_AI"]
  actions      = ["BLOCK_UPLOAD"]
}
```

Additional Terraform resources that support AI security policies include:

- **`zia_dlp_web_rules`** for applying DLP inspection to AI-bound traffic, detecting sensitive data patterns in prompts before they leave the network
- **`zia_url_filtering_rules`** for domain-level control over AI service URLs, including blocking unauthorized AI tools entirely
- **`zia_ssl_inspection_rules`** for ensuring AI traffic (including WebSocket streams) is decrypted and inspectable

## The UC14 Use Case in the Deploy Kit

The Zscaler Deploy Kit includes **UC14: AI and GenAI Control** as a new ZIA use case that combines these resources into a cohesive AI governance policy set. UC14 deploys cloud app control rules for major AI platforms (ChatGPT, Copilot, Gemini, Claude, Midjourney), applies DLP inspection to AI-bound prompts, and creates URL filtering rules that block access to unsanctioned AI services.

Like all Deploy Kit use cases, UC14 deploys in a **DISABLED** state. This is particularly important for AI security policies, where overly aggressive blocking can disrupt productivity. The recommended workflow is to deploy disabled, review the rules in the Admin Portal, enable in monitor-only mode to understand current AI usage patterns, and then gradually tighten enforcement.

## Practical Recommendations

Start with visibility before enforcement. Deploy UC14's cloud app control rules in log-only mode to discover which AI tools your organization actually uses. The results will likely surprise you -- most security teams underestimate shadow AI adoption by an order of magnitude.

Once you have a baseline, implement a tiered policy: allow sanctioned tools with DLP inspection, caution users on partially sanctioned tools, isolate high-risk AI tools through Cloud Browser Isolation, and block tools with no legitimate business purpose. Terraform makes this policy enforceable, auditable, and reproducible across environments.
