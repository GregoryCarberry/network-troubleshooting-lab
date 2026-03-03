# Incident Scenario: STP Loop / Broadcast Storm

## 1. Scenario Summary

A Layer 2 loop was introduced on the switching fabric, causing a broadcast storm that degraded or fully disrupted network connectivity across multiple VLANs.

The incident demonstrated the importance of STP behaviour, loop prevention, and validating physical patching changes.

---

## 2. Environment Context

Architecture:

- OpenWrt (Layer 3 authority: routing, DHCP, firewall)
- Zyxel GS1920-24v1 (primary distribution switch)
- Cisco SG300 (secondary managed switch for lab expansion/testing)
- VLANs in use:
  - VLAN 10 – Trusted
  - VLAN 20 – IoT
  - VLAN 30 – Guest
  - VLAN 99 – Management

Switching operates at Layer 2. Trunks carry multiple VLANs via 802.1Q.

---

## 3. Symptoms Observed

Typical indicators observed during the incident:

- Intermittent or total loss of connectivity across multiple VLANs
- High latency and packet loss (even within same VLAN)
- DHCP failures across affected segments (broadcasts overwhelmed)
- Switch CPU/management plane becomes slow or unreachable
- LEDs on switch ports show continuous heavy activity
- Wireless clients experience disconnections (if AP uplinks traverse affected switching)

---

## 4. Initial Hypotheses

Possible causes considered:

- WAN outage (Virgin Hub / ISP)
- OpenWrt CPU or service failure (dnsmasq/firewall)
- Trunk misconfiguration (tagging mismatch)
- STP misconfiguration or STP disabled
- Physical loop introduced via patch cable or accidental double-uplink
- Misbehaving device generating excessive broadcast/multicast

---

## 5. Diagnostic Steps

### Step 1 – Determine Scope (L2 vs L3)

- Test ping to default gateway from VLAN 10 (10.10.10.1)
- Test ping between two devices on same VLAN (east-west)
- Observe whether failure spans multiple VLANs simultaneously

Conclusion:
- If multiple VLANs fail at once and local VLAN traffic degrades, suspect switching / Layer 2.

---

### Step 2 – Observe Switch Behaviour

Checked on switches:

- Management interface responsiveness (web/CLI)
- Interface counters for abnormal broadcast/multicast rates
- MAC address table instability (MAC flapping across ports)
- STP status (root port, designated port, blocking state)

Common findings during loop:
- Rapidly increasing broadcast counters
- MAC flapping messages (same MAC seen on multiple ports)
- STP topology changes repeatedly

---

### Step 3 – Rapid Isolation Procedure (Stop the Bleeding)

Goal: break the loop quickly.

- Identify recent physical changes (new patch cable, new uplink, moved AP)
- Disable/shut suspected ports (starting with newest/changed)
- If uncertain, temporarily disable one trunk/uplink at a time:
  - Zyxel ↔ SG300 trunk
  - WLC uplink (if necessary)
  - AP trunk ports (if AP is bridging unexpectedly)

Connectivity typically recovers immediately once loop is broken.

---

### Step 4 – Root Confirmation

After stability returns:

- Re-enable ports one by one while monitoring:
  - broadcast/multicast counters
  - MAC table stability
  - STP state changes

Re-introducing the problematic link reproduces the storm.

---

## 6. Root Cause

A Layer 2 loop was introduced between switches (or via an improperly patched access port), creating a broadcast storm.

STP either:

- was disabled on one or more involved ports, **or**
- could not converge correctly due to port roles / misconfiguration, **or**
- loop was formed in a way that bypassed expected STP protection.

Result:
- Broadcast and unknown-unicast frames multiplied
- Switches became saturated
- Endpoints lost stable connectivity

---

## 7. Resolution

Immediate remediation:

- Removed the physical loop (unpatched redundant link / corrected cabling)
- Disabled the offending port until configuration confirmed
- Ensured trunk links were intentional and documented

Configuration hardening:

- Confirm STP enabled on both switches
- Ensure trunk ports participate correctly in STP
- Consider enabling protection features (where supported):
  - BPDU Guard / Root Guard (careful with lab intent)
  - Loop guard-like protections
  - Storm control (broadcast suppression) if available

---

## 8. Validation

Confirmed after fix:

- Stable ping to gateways on VLAN 10/20/30
- DHCP leases issue normally on all VLANs
- Switch management remains responsive
- Broadcast/multicast counters return to normal rates
- MAC table remains stable (no flapping)

Monitored for a period to ensure no recurrence.

---

## 9. Lessons Learned

- Most “whole network died” events in a LAN are Layer 2 until proven otherwise
- STP is not optional in multi-switch environments
- MAC flapping and broadcast counters are fast indicators of loops
- Controlled isolation (disable ports systematically) is the quickest recovery approach
- Document physical topology changes — loops often come from “quick patch jobs”

---

## 10. Preventative Controls Implemented

- Updated physical topology documentation to include intentional uplinks only
- Added a post-change checklist item:
  - Verify no unintended redundant uplinks exist
  - Validate STP state after cabling changes
- (Optional) Implemented storm control on edge ports to reduce blast radius