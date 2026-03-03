# Network Operations Playbook

## Purpose

This document defines the operational standards for maintaining and evolving the lab environment.

It exists to:

- Prevent configuration drift
- Standardise change control
- Ensure recovery capability
- Maintain segmentation integrity

---

## Change Control Rules

Before making changes:

- Document intended change
- Identify affected VLANs
- Define rollback plan

After making changes:

- Validate all VLANs
- Validate management access
- Confirm no unintended lateral access

---

## Baseline Validation Checklist

After any major change:

- DHCP functional on VLAN 10, 20, 30
- Internet reachable from all non-management VLANs
- VLAN 30 cannot access internal networks
- VLAN 20 cannot initiate to VLAN 10
- VLAN 99 reachable only from VLAN 10
- WAN IP is public (no double NAT)

---

## Trunk Change Checklist

Whenever modifying trunk ports:

- Confirm VLAN defined on both switches
- Confirm VLAN allowed on trunk
- Confirm tagging state
- Test DHCP on affected VLAN
- Validate ARP resolution

---

## Firewall Policy Matrix

| From → To | Allowed | Notes |
|-----------|---------|-------|
| VLAN 10 → VLAN 20 | Yes | Device management / casting |
| VLAN 20 → VLAN 10 | No | Isolation enforced |
| VLAN 30 → Any Internal | No | Guest isolation |
| VLAN 99 → Infrastructure | Yes | Management only |

Policy is intentional and explicitly enforced.

---

## Recovery Strategy

If instability occurs:

1. Revert to documented baseline
2. Validate trunk configuration
3. Confirm firewall zones
4. Confirm WAN boundary
5. Reintroduce experimental changes incrementally

---

## Operational Philosophy

This lab is treated as production-grade infrastructure.

Experimentation is intentional.
Baseline state is controlled.
Policy is explicit.
Validation is mandatory.