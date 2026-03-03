# Incident Scenario: DHCP Failure on Segmented VLAN

## 1. Scenario Summary

Clients on a specific VLAN failed to obtain IP addresses via DHCP.

The failure was isolated to a single VLAN while others continued functioning normally.

This scenario demonstrates systematic isolation of Layer 2 vs Layer 3 faults and broadcast-path validation.

---

## 2. Environment Context

Architecture:

- OpenWrt (Layer 3 authority: DHCP, routing, firewall)
- Zyxel GS1920-24v1 (primary switch)
- Cisco SG300 (secondary switch)
- VLAN segmentation:
  - VLAN 10 – Trusted
  - VLAN 20 – IoT
  - VLAN 30 – Guest
  - VLAN 99 – Management

Each VLAN has:

- Dedicated interface on OpenWrt
- Independent DHCP scope via dnsmasq
- Routed gateway at 10.10.X.1

---

## 3. Symptoms Observed

- Devices on VLAN 30 (Guest) failed to obtain IP addresses
- Clients showed:
  - “Obtaining IP address…” indefinitely
  - Self-assigned 169.254.x.x addresses (APIPA)
- Other VLANs (10, 20, 99) functioning normally
- No WAN outage

---

## 4. Initial Hypotheses

Possible causes considered:

- dnsmasq service failure
- DHCP scope misconfiguration
- VLAN interface down on OpenWrt
- Firewall blocking DHCP
- Trunk misconfiguration (broadcast not reaching router)
- Access port assigned to wrong VLAN

---

## 5. Diagnostic Steps

### Step 1 – Confirm Scope of Failure

Tested:

- VLAN 10 DHCP → Working
- VLAN 20 DHCP → Working
- VLAN 30 DHCP → Failing

Conclusion:
- DHCP service likely operational
- Issue isolated to one VLAN

---

### Step 2 – Validate DHCP Service on Router

On OpenWrt:

- Confirmed dnsmasq running
- Verified VLAN 30 interface exists (br-vlan30)
- Confirmed DHCP scope defined for 10.10.30.0/24
- Reviewed logs for errors

Result:
- No service failure detected

Conclusion:
- DHCP server operational
- Likely Layer 2 delivery issue

---

### Step 3 – Test Static Assignment

Configured test client manually:

- IP: 10.10.30.50
- Gateway: 10.10.30.1
- DNS: 10.10.30.1

Results:

- Unable to ping 10.10.30.1
- ARP resolution incomplete

Conclusion:
- VLAN traffic not reaching gateway
- Strong indicator of tagging or trunk issue

---

### Step 4 – Inspect Switch Configuration

Checked:

- Access port VLAN assignment
- Trunk allow-list between switches
- VLAN 30 tagging state

Finding:

- VLAN 30 defined on switches
- VLAN 30 missing from one trunk’s allowed VLAN list

DHCP broadcast (UDP 67/68) was not reaching OpenWrt.

---

## 6. Root Cause

VLAN 30 was not properly propagated across a trunk link.

As a result:

- DHCP broadcast packets never reached OpenWrt
- ARP requests for 10.10.30.1 failed
- Clients defaulted to APIPA addresses

This was a Layer 2 VLAN propagation issue — not a DHCP service failure.

---

## 7. Resolution

Actions taken:

- Updated trunk configuration to explicitly allow VLAN 30
- Verified consistent tagging across trunk links
- Ensured access ports remained untagged in VLAN 30

After correction:

- DHCP leases assigned immediately
- Gateway reachable
- Internet access restored

---

## 8. Validation

Confirmed:

- DHCP assignment on VLAN 30
- Ping to 10.10.30.1 successful
- Internet connectivity functional
- No impact to other VLANs

Monitored for recurrence after configuration change.

---

## 9. Lessons Learned

- Always test DHCP per VLAN after trunk changes
- DHCP failures are often Layer 2 issues in segmented networks
- Static IP testing quickly differentiates L2 vs L3 faults
- Broadcast-based services are early detection signals for VLAN misconfiguration
- Multi-vendor trunk validation requires checking both ends

---

## 10. Preventative Controls Implemented

- Added trunk VLAN audit to deployment checklist
- Implemented post-change validation:
  - DHCP test per VLAN
  - Gateway ping test
  - ARP table inspection
- Standardized trunk configuration template across switches