# Architecture Versioning

> This document tracks stable architectural milestones of the Network Troubleshooting Lab.
> Version numbers represent controlled baseline states — not experimental snapshots.

## Purpose

This document defines **versioned baseline states** of the Network Troubleshooting Lab so the repository stays aligned with the real network as the lab evolves.

It exists to:

- prevent documentation drift
- provide a clear “known-good” reference point
- separate baseline architecture from experimental work
- support future transitions (e.g., observability)

---

## Baseline Versions

### v1.0 — Segmentation Baseline (Post Config Refactor)

**Status:** Current baseline  
**Focus:** VLAN segmentation + routing/firewall policy + enterprise wireless integration  
**Change control:** All changes validated using the baseline checklist

#### VLAN Model

| VLAN | Name | Subnet | Gateway | Notes |
|------|------|--------|---------|------|
| 10 | Trusted | 10.10.10.0/24 | 10.10.10.1 | Admin/workstations |
| 20 | IoT | 10.10.20.0/24 | 10.10.20.1 | Smart devices / casting |
| 30 | Guest | 10.10.30.0/24 | 10.10.30.1 | Isolated guest access |
| 99 | Management | 10.10.99.0/24 | 10.10.99.1 | Infrastructure management |

#### Role Ownership

- **Virgin Hub (modem mode):** WAN termination only  
- **OpenWrt (HH5A):** Single Layer 3 authority (routing, DHCP, firewall, NAT)  
- **Zyxel GS1920-24v1:** Primary distribution switch (L2 VLAN trunking)  
- **Cisco SG300:** Secondary switch for expansion/testing (L2 VLAN trunking, STP experiments)  
- **Cisco 2504 WLC:** WLAN control, SSID-to-VLAN mapping, AP management  
- **Cisco APs (2602/3802):** Trunked uplinks, VLAN-mapped SSIDs

#### Inter-VLAN Policy Model (Intent)

Default: deny lateral movement.

- VLAN 10 → VLAN 20: allowed (controlled access / casting / testing)
- VLAN 20 → VLAN 10: denied
- VLAN 30 → internal VLANs: denied
- VLAN 99 (mgmt): reachable from VLAN 10 only

#### Wireless Mapping

- Trusted SSID → VLAN 10
- IoT SSID → VLAN 20
- Guest SSID → VLAN 30
- AP/WLC management → VLAN 99

---

## Known Constraints (v1.0)

- Some device management/export workflows are vendor-specific (Zyxel UI exports, SG300 config capture, WLC show commands)
- Archived configs exist for historical reference only and are not considered baseline
- VLAN changes must be validated end-to-end (trunks, DHCP, firewall, wireless mapping)

---

## Validation Checklist (v1.0)

After any significant change:

- DHCP works on VLAN 10/20/30
- Clients can ping their VLAN gateway (10.10.X.1)
- Internet access works from VLAN 10/20/30
- VLAN 30 cannot access internal VLANs
- VLAN 20 cannot initiate connections to VLAN 10
- VLAN 99 management reachable only from VLAN 10
- WLC reachable and APs joined (if wireless in use)
- No STP instability or MAC flapping observed

---

## Next Version Plan

### v1.1 — Observability Layer (Planned)

Target additions:

- Central logging
- Metrics collection
- Dashboards (Grafana)
- Optional flow telemetry (NetFlow/sFlow experimentation)

When v1.1 begins, this file will be updated with:

- new components
- new failure modes/scenarios
- updated validation requirements