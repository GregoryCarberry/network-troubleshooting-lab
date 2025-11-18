# Network Troubleshooting Lab – Scenario Index

This file provides a quick index of all documented troubleshooting scenarios in the lab.

Each scenario lives in the `scenarios/` directory and follows the structure:
- Overview
- Topology
- Symptoms
- Possible Root Causes
- Reproduction Steps
- Diagnostic Workflow
- Example Root Cause
- Resolution
- Lessons Learned

## Scenarios

1. **Scenario 01 – DHCP Failure on Lab Subnet**  
   File: `scenarios/01-dhcp-failure.md`  
   Focus: DHCP server outages, bad scopes, wrong VLAN, rogue DHCP.

2. **Scenario 02 – DNS Outage / DNS Misconfiguration**  
   File: `scenarios/02-dns-outage.md`  
   Focus: Broken DNS, wrong DHCP DNS options, resolver failures, firewall issues.

3. **Scenario 03 – VLAN Misconfiguration (Client Isolated from Network)**  
   File: `scenarios/03-vlan-misconfig.md`  
   Focus: Wrong access VLAN, trunk misconfig, native VLAN mismatch.

4. **Scenario 04 – Routing Issue (Incorrect or Missing Route)**  
   File: `scenarios/04-routing-issue.md`  
   Focus: Bad default gateway, missing routes, NAT/routing failures.

5. **Scenario 05 – STP Loop / Broadcast Storm**  
   File: `scenarios/05-stp-loop.md`  
   Focus: Physical loops, broadcast storms, STP configuration.

6. **Scenario 06 – Double NAT (Incorrect or Unexpected NAT Chaining)**  
   File: `scenarios/06-double-nat.md`  
   Focus: Virgin Hub + OpenWRT NAT chaining, port forwarding and VPN issues.

## Usage

These scenarios are designed to be:
- Practised in the lab
- Referenced during interviews
- Updated over time as new insights are gained
