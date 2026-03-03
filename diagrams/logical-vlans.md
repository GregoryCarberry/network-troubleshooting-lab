# Logical VLAN Architecture

## Overview

The lab network is segmented using IEEE 802.1Q VLAN tagging with OpenWrt acting as the Layer 3 authority (inter-VLAN routing and firewall enforcement).

The objective of segmentation is to:

- Isolate untrusted and IoT devices
- Enforce controlled inter-VLAN routing
- Simulate enterprise network design patterns
- Enable failure simulation and troubleshooting scenarios

---

## VLAN Summary

| VLAN ID | Name        | Subnet            | Gateway        | Purpose |
|----------|------------|-------------------|---------------|----------|
| 10       | Trusted    | 10.10.10.0/24     | 10.10.10.1     | Workstations, admin devices |
| 20       | IoT        | 10.10.20.0/24     | 10.10.20.1     | Smart devices, Chromecast, IoT endpoints |
| 30       | Guest      | 10.10.30.0/24     | 10.10.30.1     | Isolated guest Wi-Fi |
| 99       | Management | 10.10.99.0/24     | 10.10.99.1     | Network infrastructure (WLC, switches, router mgmt) |

---

## Layer 3 Authority

OpenWrt (BT HomeHub 5A) provides:

- Inter-VLAN routing
- DHCP per VLAN
- Firewall enforcement between VLANs
- NAT toward WAN
- Static route to Virgin Hub (192.168.100.1) for modem access

All VLAN interfaces terminate on OpenWrt.

---

## Trunking Design

802.1Q trunking is used between:

- OpenWrt ↔ Zyxel GS1920
- Zyxel GS1920 ↔ Cisco SG300
- Switch ↔ WLC (management VLAN tagged)
- Switch ↔ Access Points (trunk for multi-SSID mapping)

Access ports are assigned per device role.

---

## Inter-VLAN Policy Model

Default stance: deny lateral movement.

High-level policy:

- Trusted → IoT: allowed (for casting, management)
- Trusted → Guest: denied
- IoT → Trusted: denied
- Guest → All internal VLANs: denied
- Management VLAN: restricted to infrastructure access only

Firewall enforcement occurs at OpenWrt.

---

## Wireless VLAN Mapping

SSIDs are mapped to VLANs on the WLC:

- Main SSID → VLAN 10 (Trusted)
- IoT SSID → VLAN 20
- Guest SSID → VLAN 30

AP management traffic is carried on VLAN 99.

---

## Design Rationale

This segmentation model allows:

- Safe IoT experimentation
- Firewall rule testing
- Inter-VLAN troubleshooting scenarios
- Enterprise-style wireless VLAN mapping
- Failure injection without impacting management access

The architecture mirrors small-to-mid enterprise segmentation practices using mixed consumer and enterprise hardware.