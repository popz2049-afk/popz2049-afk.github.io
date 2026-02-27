---
title: "Zero Trust Branch: Replacing SD-WAN with Zero Trust"
date: 2026-02-27
draft: false
description: "How Zscaler Zero Trust Branch eliminates branch appliance sprawl by replacing SD-WAN, firewalls, and NAC with a single Zero Trust architecture."
summary: "Zscaler Zero Trust Branch replaces five categories of branch appliances -- SD-WAN, firewalls, NAC, VPN concentrators, and load balancers -- with a unified Zero Trust architecture. This post covers the branch problem, ZT appliance hardware, the Airgap acquisition for IoT/OT segmentation, and the dedicated ztc Terraform provider."
tags: ["ztb", "sd-wan", "branch", "iot", "ot", "airgap"]
categories: ["Deep Dives"]
showTableOfContents: true
---

## The Branch Problem

Traditional branch office networking is built on implicit trust. An MPLS circuit connects the branch to headquarters. A branch firewall provides perimeter security. An SD-WAN appliance optimizes traffic routing. A NAC solution manages device admission. A VPN concentrator provides remote access. Each appliance has its own management plane, its own firmware update cycle, its own licensing model, and its own failure modes.

The result is a flat trusted network inside every branch. Once a device is on the LAN -- whether it is a managed laptop, an IoT sensor, a security camera, or a compromised printer -- it can communicate freely with every other device on the same network. Lateral movement inside a branch is trivial. An attacker who compromises a single IoT device gains a foothold from which every other branch resource is reachable.

This architecture also creates operational burden at scale. An organization with 200 branch offices maintains 200 sets of appliances, each requiring configuration management, firmware patching, hardware replacement, and troubleshooting. The total cost of ownership -- hardware, licensing, engineering time, and security risk -- is substantial.

## What Zero Trust Branch Replaces

Zscaler Zero Trust Branch (ZTB) eliminates five categories of branch appliances:

1. **SD-WAN routers** -- Replaced by ZT appliance DTLS/TLS tunnels to Zscaler cloud over any broadband connection
2. **Branch firewalls** -- Replaced by ZIA cloud firewall policies applied to all branch traffic
3. **NAC (Network Access Control)** -- Replaced by agentless device segmentation from the Airgap acquisition
4. **VPN concentrators** -- Replaced by ZPA private access policies with no inbound ports
5. **Load balancers** -- Replaced by Zscaler cloud-native traffic distribution

The architectural principle is that every branch becomes a "coffee shop" from a trust perspective. No device on the branch LAN is trusted by default. All traffic -- whether destined for the internet, headquarters, another branch, or a device on the same LAN -- is mediated through Zscaler's cloud security stack.

## ZT Appliance Hardware

ZTB runs on purpose-built hardware deployed at each branch:

| Model | Throughput | Use Case |
|-------|-----------|----------|
| **ZT 400** | 200 Mbps | Small branches, retail locations |
| **ZT 600** | 500 Mbps | Medium branches, regional offices |
| **ZT 800** | 1 Gbps | Large branches, campus buildings |
| **ZT VM** | Varies | Virtual deployments, lab environments |

All models support **Zero Touch Provisioning** -- the appliance is shipped to the branch, plugged into any broadband connection, and automatically connects to the Zscaler cloud. No on-site IT staff is required for deployment. The appliance downloads its configuration from the cloud and begins forwarding traffic through DTLS tunnels to ZIA and TLS tunnels to ZPA.

## The Airgap Acquisition and IoT/OT Segmentation

In April 2024, Zscaler acquired **Airgap Networks**, a company specializing in agentless network segmentation. This acquisition is critical to the Zero Trust Branch story because it solves the IoT/OT problem.

Traditional Zero Trust architectures rely on agents (like Zscaler Client Connector) installed on endpoints. This works for managed laptops and phones. It does not work for IoT sensors, security cameras, industrial control systems, building management systems, medical devices, or any device that cannot run a software agent.

Airgap's technology creates a **"Network of One"** for each device on the branch LAN. Every device is placed in its own micro-segment, regardless of whether it runs an agent. Communication between devices is brokered through policy -- a security camera can reach its recording server but nothing else. A building management sensor can report to its controller but cannot initiate connections to the corporate network.

This is agentless segmentation at the network layer, enforced by the ZT branch appliance. It eliminates the flat branch LAN without requiring any software installation on the devices being segmented.

## The ztc Terraform Provider

Unlike Zscaler Deception (which has no IaC support), Zero Trust Branch has a **dedicated Terraform provider**: `zscaler/ztc` on the Terraform Registry. This provider manages branch connectivity resources including:

- **`ztc_provisioning_url`** -- Generate provisioning URLs for zero-touch appliance deployment
- **`ztc_traffic_forwarding_rule`** -- Define how branch traffic is forwarded to Zscaler cloud
- **`ztc_traffic_forwarding_dns_rule`** -- DNS-based traffic forwarding rules
- **`ztc_location_management`** -- Manage branch location configurations
- **`ztc_activation_status`** -- Control activation state of branch configurations

Additionally, the official **Cloud Connector modules** (`zscaler/cloud-connector-modules/aws|azurerm|gcp`) provide Terraform modules for deploying cloud-hosted connectors that extend Zero Trust Branch into public cloud environments.

## The Trust Model Shift

The philosophical shift behind Zero Trust Branch is worth emphasizing. Traditional branch networking assumes the branch LAN is a trusted zone. Security is applied at the perimeter -- the firewall between the branch and the outside world. Everything inside that perimeter communicates freely.

Zero Trust Branch inverts this assumption. The branch LAN is untrusted. Every flow -- even between two devices sitting on the same switch -- is subject to policy. Internet-bound traffic goes through ZIA for inspection. Private application access goes through ZPA with identity and posture verification. Device-to-device communication is brokered through Airgap segmentation policies.

The practical result is that compromising a single branch device no longer provides lateral movement to other branch resources. Each device is isolated by default, and every connection requires explicit authorization. The branch becomes as secure as if every device were connecting from a public coffee shop -- which is exactly the point.

For Deploy Kit users, Zero Trust Branch represents the next frontier of IaC-managed Zscaler infrastructure. The `ztc` provider and Cloud Connector modules bring branch provisioning into the same Terraform workflow that already manages your ZIA and ZPA policies.
