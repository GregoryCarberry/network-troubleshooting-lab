# Network Troubleshooting Lab

A hands-on network troubleshooting lab focused on diagnosing and resolving Layer 2–Layer 4 issues using realistic hardware and configurations.

The lab uses a mix of consumer, SMB, and enterprise-style equipment to reflect environments commonly encountered in operational IT and networking roles.

---

## Scope

This repository documents a modular troubleshooting lab used to examine:

- Switching vs routing boundaries
- VLAN behaviour and management
- DHCP, DNS, NAT, and firewall interactions
- Fault isolation across multi-device network paths

The emphasis is on reproducibility, clear evidence, and documented outcomes.

---

## Current Active Topology (Authoritative)

```
Internet
  ↓
Virgin Media Hub (modem mode)
  ↓
BT Home Hub 5A (OpenWrt)
  - Edge router (NAT, firewall, DHCP)
  - VLAN-aware access point
  ↓
Cisco SG300-28
  - Managed switch (Layer 2)
  - VLAN segmentation & management
  ↓
Lab clients / test devices
```

The BT Home Hub 5A running OpenWrt is the only Layer 3 device in the lab.
The Cisco SG300-28 operates at Layer 2 for switching and VLAN separation.

---

## Hardware in Use

### Networking

- **Cisco SG300-28**
  - Managed switch
  - VLAN configuration (access and trunk ports)
  - Switch management via dedicated management IP

- **BT Home Hub 5A (OpenWrt)**
  - Edge router and access point
  - Provides:
    - WAN DHCP client
    - NAT (masquerading)
    - Firewalling
    - LAN DHCP and DNS
  - Configuration and recovery notes are documented in `configs/openwrt/hh5a-ap1`

- **Virgin Media Hub**
  - Operating in modem mode only
  - Management interface available at `192.168.100.1`
  - No routing, NAT, or wireless services enabled

### Secondary / Comparative Hardware

- **Zyxel GS1920-24**
  - Managed switch with GUI-focused management
  - Limited CLI functionality
  - Reserved for comparative labs examining:
    - Enterprise CLI vs SMB GUI workflows
    - Management plane limitations
    - Mixed-vendor operational trade-offs

---

## Available Hardware for Future Labs

The following devices are not part of the active topology but are available for future scenarios:

- **3 × Cisco AIR-SAP2602I-E-K9**
  - Wireless access point configuration
  - SSID design and security modes
  - Roaming and client behaviour

- **1 × Alfa AWUS051NH v2**
  - Wireless client diagnostics
  - Packet capture and monitor-mode testing
  - Client-side troubleshooting scenarios

---

## Implemented Scenarios

- Verified end-to-end routing from LAN clients to WAN
- Documented NAT and firewall forwarding behaviour
- Validated VLAN handling through a managed switch
- Captured and documented a routing fault scenario:
  - LAN clients unable to reach WAN despite router connectivity
  - Root cause traced to NAT / forwarding configuration

Known-good configurations are archived for recovery and repeat testing.

---

## Deferred Areas

The following areas are intentionally out of scope at this stage:

- Inter-VLAN routing
- Wireless roaming optimisation
- IDS / traffic inspection
- Advanced firewall hardening

These are deferred to keep individual scenarios focused and isolated.

---

## Repository Structure (High Level)

- `configs/`
  - Router and switch configurations
- `scripts/`
  - Diagnostic and testing utilities
- `diagrams/`
  - Physical and logical topology notes
- `SCENARIOS.md`
  - Planned and completed troubleshooting scenarios

---

## Notes

This repository is structured to support incremental expansion.
Each component is documented locally, with higher-level narrative captured separately for portfolio use.
