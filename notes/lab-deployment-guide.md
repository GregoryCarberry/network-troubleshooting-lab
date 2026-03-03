
# Lab Deployment Guide

## Purpose

This document defines the baseline deployment state of the Network Troubleshooting Lab.

It exists to:

- Establish a clean, known-good configuration
- Prevent architectural drift
- Provide a reproducible recovery reference
- Separate baseline design from experimental changes

This guide reflects the CURRENT production baseline of the lab.

---

## WAN Boundary

### Virgin Media Hub
- Operating Mode: Modem Mode
- Routing: Disabled
- DHCP: Disabled
- Management IP: 192.168.100.1 (reachable via static route from VLAN 10)

The modem is treated purely as a Layer 2 WAN termination device.

---

## Layer 3 Authority

### OpenWrt (BT HomeHub 5A)

OpenWrt is the single Layer 3 authority.

Responsibilities:

- Inter-VLAN routing
- DHCP per VLAN
- Firewall enforcement
- NAT to WAN
- Static route to modem interface

### VLAN Interfaces

| VLAN | Interface | Subnet | Gateway |
|------|----------|--------|----------|
| 10 | br-vlan10 | 10.10.10.0/24 | 10.10.10.1 |
| 20 | br-vlan20 | 10.10.20.0/24 | 10.10.20.1 |
| 30 | br-vlan30 | 10.10.30.0/24 | 10.10.30.1 |
| 99 | br-vlan99 | 10.10.99.0/24 | 10.10.99.1 |

Each VLAN runs independent DHCP scope via dnsmasq.

---

## Firewall Model

Default policy: deny lateral movement.

High-level policy:

- Trusted → IoT: allowed (controlled access for casting / testing)
- Trusted → Guest: denied
- IoT → Trusted: denied
- Guest → All internal VLANs: denied
- VLAN 99 (Management): restricted to VLAN 10 only

WAN access is permitted from VLAN 10, 20, and 30 via NAT.

Firewall rules are centrally enforced on OpenWrt.

---

## Switching Baseline

### Zyxel GS1920-24v1 (Primary Distribution Switch)

- Uplink to OpenWrt: 802.1Q trunk
- Trunk to Cisco SG300
- Trunk to WLC
- Access ports assigned per VLAN

No Layer 3 functionality is enabled.

---

### Cisco SG300

- Operates in Layer 2 mode
- Used for trunk validation, STP testing, VLAN propagation experiments
- No routing enabled

---

## Wireless Deployment

### Cisco 2504 WLC

- Management interface: VLAN 99
- WLAN-to-VLAN mapping configured
- AP management via VLAN 99

### SSID Mapping

| SSID | VLAN |
|------|------|
| Trusted | 10 |
| IoT | 20 |
| Guest | 30 |

AP switch ports are configured as trunks carrying VLAN 10, 20, 30, and 99.

---

## Management Access Policy

Management interfaces are only reachable from VLAN 10.

Devices protected:

- OpenWrt admin interface
- Zyxel management
- SG300 management
- WLC GUI/CLI
- AP management

Guest and IoT VLANs have no access to infrastructure management.

---

## Baseline Validation Checklist

After deployment or major changes, validate:

- DHCP assignment on all VLANs
- Internet access from VLAN 10, 20, 30
- No lateral access from VLAN 30
- IoT cannot initiate connections to VLAN 10
- Management interfaces reachable only from VLAN 10
- Trunk ports correctly tagging traffic
- APs join WLC successfully

---

## Change Control Philosophy

Experiments are performed intentionally and documented separately.

This file defines the stable recovery baseline.

If troubleshooting becomes unstable, revert to this configuration before introducing further variables.
