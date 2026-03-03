# Physical Topology

## Overview

The lab combines consumer and enterprise hardware to simulate real-world mixed-environment network design.

The physical layout is structured to:

- Separate WAN and LAN boundaries clearly
- Centralize Layer 3 control on OpenWrt
- Use managed switching for VLAN trunking
- Support enterprise wireless via WLC + APs
- Allow controlled failure testing and segmentation experiments

---

## Physical Layout

Internet
   │
   ▼
Virgin Media Hub (Modem Mode)
   │  (WAN)
   ▼
OpenWrt Router (BT HomeHub 5A)
   │ 802.1Q trunk
   ▼
Zyxel GS1920-24v1 (Primary Distribution Switch)
   │
   ├── Trunk → Cisco SG300 (Access / Lab Expansion)
   ├── Trunk → Cisco 2504 WLC (Mgmt VLAN 99 + WLAN VLANs)
   ├── Access → Wired Trusted Devices (VLAN 10)
   ├── Access → IoT Devices (VLAN 20)
   └── Access → Guest Network Ports (VLAN 30)

Wireless APs connect via trunk ports to allow:

- VLAN 10 (Trusted SSID)
- VLAN 20 (IoT SSID)
- VLAN 30 (Guest SSID)
- VLAN 99 (AP management)

---

## Device Roles

### Virgin Hub
- Operates in modem mode
- No DHCP or routing
- Accessible via static route (192.168.100.1) from VLAN 10

---

### OpenWrt (Layer 3 Authority)

Responsibilities:
- Inter-VLAN routing
- DHCP per VLAN
- Firewall policy enforcement
- NAT to WAN
- Static routing to modem

This is the single Layer 3 boundary in the lab.

---

### Zyxel GS1920-24v1

Primary distribution switch.

Responsibilities:
- VLAN tagging
- 802.1Q trunking
- Access port segmentation
- Uplink to SG300
- Uplink to WLC

---

### Cisco SG300

Secondary managed switch used for:

- Lab isolation testing
- Trunk experiments
- STP testing
- VLAN propagation validation

Operates strictly at Layer 2 in this topology.

---

### Cisco 2504 Wireless LAN Controller

- Management interface on VLAN 99
- WLAN-to-VLAN mapping
- Centralized SSID control
- AP management and provisioning

---

### Cisco Access Points (2602 / 3802)

Connected via trunk ports.

Carry:
- Management traffic (VLAN 99)
- SSID-to-VLAN mapped traffic

Used to test:
- Wireless segmentation
- Multicast behaviour (Chromecast testing)
- Roaming scenarios
- RF behaviour comparisons

---

## Management Access Strategy

Management VLAN (99) is isolated.

Only trusted devices on VLAN 10 can access:

- OpenWrt admin interface
- Switch management
- WLC GUI/CLI
- AP management

Guest and IoT VLANs are blocked from management access.

---

## Design Philosophy

The lab intentionally mixes consumer and enterprise hardware to:

- Simulate real-world constraints
- Practice VLAN propagation across vendors
- Diagnose trunk mismatches
- Validate firewall enforcement boundaries
- Experiment with wireless VLAN tagging

The physical topology supports both stable baseline operation and controlled misconfiguration scenarios for troubleshooting practice.