# Network Segmentation & Troubleshooting Lab

> Updated: Feb 2026  
> Category: Network Engineering Lab  
> Focus: Multi-VLAN Segmentation, Policy Enforcement, Wireless Integration  

---

## Overview

This repository documents a physical network engineering lab built on enterprise and SMB hardware.

Originally created as a troubleshooting environment, the lab has evolved into a segmented, policy-driven multi-VLAN architecture designed around:

- Controlled trust boundaries
- Centralised Layer 3 authority
- Explicit firewall rule directionality
- Deliberate management-plane isolation
- Consistent wired + wireless segmentation

The objective is not just connectivity — but controlled connectivity.

---

## Authoritative Topology

High-Level Flow:

Internet (Virgin Hub – Modem Mode)
↓
OpenWrt (BT Home Hub 5A)
- NAT (masquerade)
- Firewall enforcement
- DHCP / DNS
- Inter-VLAN routing
↓ 802.1Q trunk (VLANs 10 / 20 / 30 / 99)
Zyxel GS1920-24 (Layer 2 only)
↓ 802.1Q trunk
Cisco SG300-28 (Layer 2 only)
↓
Access ports & trunked wireless APs

Routing authority is centralised on OpenWrt.
Both switches operate strictly at Layer 2.

---

## VLAN Architecture

| VLAN | Name        | Purpose        | Behaviour |
|------|------------|---------------|-----------|
| 10   | Trusted     | Primary LAN    | Can reach VLAN 20 & 99 |
| 20   | IoT         | Restricted LAN | Cannot initiate to VLAN 10 or 99 |
| 30   | Guest       | Internet-only  | No internal access |
| 99   | Management  | Infrastructure | Cannot initiate to user VLANs |

### Policy Model

- VLAN 10 → VLAN 20: Allowed
- VLAN 20 → VLAN 10: Blocked
- VLAN 30 → Internal VLANs: Blocked
- VLAN 99 → User VLANs: Blocked
- All VLANs → WAN: NAT via OpenWrt

Security and routing decisions are enforced exclusively at Layer 3 on OpenWrt.

Switches do not perform inter-VLAN routing.

---

## Layer 2 Design Principles

Zyxel GS1920-24 and Cisco SG300-28:

- 802.1Q trunking
- Access port segmentation
- No Layer 3 routing
- Clear separation of switching vs routing roles
- Comparative platform testing (SMB GUI vs enterprise-style CLI)

Switch configuration errors (mis-tagging, trunk failures, VLAN leaks) are deliberately tested and documented.

---

## Layer 3 Authority (OpenWrt)

OpenWrt acts as the single Layer 3 boundary.

Responsibilities:

- Inter-VLAN routing
- NAT (WAN masquerading)
- Firewall policy enforcement
- DHCP and DNS services

Key Design Rule:

Switching ≠ Routing

All policy enforcement and trust boundary decisions are centralised.

---

## Wireless Architecture

- Cisco WLC 2504 placed in VLAN 99 (Management)
- Cisco 2602i and 3802i APs trunked to switches
- SSIDs mapped to VLANs 10 / 20 / 30
- Wireless segmentation mirrors wired segmentation
- No policy exceptions for wireless clients

Wireless clients are subject to identical Layer 3 firewall policy as wired devices.

---

## Documented Failure Scenarios

This lab intentionally introduces faults to validate troubleshooting methodology.

Examples:

### LAN Clients Cannot Reach Internet
Root Cause: Misconfigured forwarding or NAT rule.

Validation:
- Confirm router WAN connectivity
- Confirm firewall zone forwarding
- Validate masquerade rules

---

### Management Plane Isolation
Management VLAN intentionally unreachable from user VLANs.

Lesson:
Isolation is expected behaviour.
Access must be explicitly permitted.

---

### VLAN Misconfiguration / Trunk Errors
Incorrect tagging or PVID assignments can produce partial connectivity or isolation leaks.

Validation includes:
- Port membership verification
- Cross-VLAN testing
- Real traffic (HTTP/DNS) validation

---

## Troubleshooting Framework

Structured fault isolation approach:

1. Physical link status
2. VLAN tagging verification
3. IP addressing & gateway validation
4. Firewall rule directionality
5. NAT / masquerade behaviour
6. Real application traffic testing

ICMP alone is not considered sufficient validation.

---

## Design Tradeoffs

- Centralised routing simplifies policy control
- Switches remain Layer 2 for clarity of responsibility
- Management plane isolated by default
- Dual-switch architecture retained for cross-platform familiarity
- Wireless integrated without bypassing segmentation rules

---

## Why This Lab Exists

This repository documents applied network engineering practice.

It demonstrates:

- Multi-VLAN segmented design
- Controlled trust boundaries
- Centralised firewall enforcement
- Wireless + wired policy consistency
- NAT behaviour and forwarding logic
- Clear Layer 2 vs Layer 3 responsibility
- Real-world fault isolation methodology

The lab evolves incrementally, with configuration snapshots preserved for reproducibility and rollback.

---

## Status

Active and expanding.

Future areas may include:

- Additional wireless optimisation testing
- Comparative routing models
- Enhanced logging and monitoring
- Extended policy complexity

Segmentation is enforced, tested, and validated using real client traffic.
