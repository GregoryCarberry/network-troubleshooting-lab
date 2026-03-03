
# Network Troubleshooting Lab

## Overview

This project is a structured home lab designed to simulate real-world network architecture, segmentation, and troubleshooting scenarios using a mix of consumer and enterprise hardware.

The goal is not just connectivity — it is controlled design, fault injection, and structured incident resolution.

This lab demonstrates:

- VLAN segmentation using 802.1Q trunking
- Inter-VLAN routing with firewall enforcement
- Enterprise wireless integration (WLC + APs)
- Mixed-vendor switch interoperability
- Failure simulation and structured troubleshooting
- Controlled management plane isolation

---

## Architecture Summary

### Core Design Principles

- Single Layer 3 authority (OpenWrt)
- Strict inter-VLAN firewall policy
- Segmented wireless SSIDs mapped to VLANs
- Isolated management plane
- Mixed consumer + enterprise hardware by design

---

## VLAN Model

| VLAN ID | Name        | Subnet            | Purpose |
|----------|------------|-------------------|----------|
| 10       | Trusted    | 10.10.10.0/24     | Admin devices and workstations |
| 20       | IoT        | 10.10.20.0/24     | Smart devices and casting endpoints |
| 30       | Guest      | 10.10.30.0/24     | Isolated guest access |
| 99       | Management | 10.10.99.0/24     | Network infrastructure management |

OpenWrt handles:

- DHCP per VLAN
- Inter-VLAN routing
- Firewall enforcement
- NAT toward WAN
- Static route to modem interface

---

## Hardware Stack

- Virgin Media Hub (Modem Mode)
- OpenWrt (BT HomeHub 5A) – Layer 3 authority
- Zyxel GS1920-24v1 – Primary distribution switch
- Cisco SG300 – Secondary managed switch
- Cisco 2504 Wireless LAN Controller
- Cisco 2602 & 3802 Access Points

---

## Wireless Architecture

- SSID (Trusted) → VLAN 10
- SSID (IoT) → VLAN 20
- SSID (Guest) → VLAN 30
- AP Management → VLAN 99

This enables controlled multicast testing, casting validation, roaming experiments, and VLAN isolation validation.

---

## What This Lab Demonstrates

This project reflects practical infrastructure engineering skills:

- Designing segmented networks
- Enforcing least-privilege routing policies
- Debugging trunk mismatches
- Diagnosing DHCP and DNS failures
- Validating multicast behavior across VLANs
- Handling mixed-vendor switching environments
- Working with enterprise wireless controllers

---

## Troubleshooting Scenarios

Structured scenarios are documented in `/scenarios` including:

- DHCP failure simulation
- DNS outage analysis
- VLAN misconfiguration
- Inter-VLAN routing failures
- STP loop testing
- Double NAT diagnostics

Each scenario includes:

- Detection method
- Diagnostic process
- Root cause
- Resolution
- Preventative improvement

---

## Design Philosophy

This is not a passive home network.

It is an actively engineered and intentionally stressed environment designed to:

- Develop structured troubleshooting methodology
- Simulate enterprise segmentation practices
- Validate configuration discipline
- Build repeatable operational documentation

---

## Future Enhancements

Planned evolution includes:

- Centralized logging
- Metrics dashboards (Grafana)
- NetFlow/sFlow experimentation
- Wireless RF behavior comparison (2602 vs 3802)
- Automated configuration validation

---

## Repository Structure

/docs – Architectural documentation  
/configs – Redacted configuration baselines  
/scenarios – Structured troubleshooting simulations  
/scripts – Diagnostic utilities  

---

This lab represents continuous iterative improvement and documentation refinement.
