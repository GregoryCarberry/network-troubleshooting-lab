# Incident Scenario: VLAN Trunk Mismatch

## 1. Scenario Summary

Clients connected to VLAN 20 (IoT) failed to obtain IP addresses and had no network connectivity.

The issue occurred after switch configuration changes involving trunk ports between the Zyxel GS1920 and Cisco SG300.

---

## 2. Environment Context

Architecture:

- OpenWrt (Layer 3 authority)
- Zyxel GS1920-24v1 (primary distribution switch)
- Cisco SG300 (secondary managed switch)
- VLAN 10 – Trusted
- VLAN 20 – IoT
- VLAN 30 – Guest
- VLAN 99 – Management

Inter-VLAN routing and DHCP services are provided by OpenWrt.

Switches operate strictly at Layer 2.

---

## 3. Symptoms Observed

- Devices on VLAN 20 received no DHCP lease
- Manual static IP assignment did not restore connectivity
- No internet access from affected VLAN
- VLAN 10 devices continued operating normally
- Management VLAN unaffected

---

## 4. Initial Hypotheses

Possible causes considered:

- DHCP service failure on OpenWrt
- Firewall rule blocking DHCP
- Access port misassignment
- Trunk misconfiguration between switches
- Incorrect VLAN tagging (tagged vs untagged mismatch)

---

## 5. Diagnostic Steps

### Step 1 – Validate DHCP Service

Confirmed via OpenWrt:

- dnsmasq running
- DHCP scope active for VLAN 20
- No errors in logs

Conclusion: DHCP server operational.

---

### Step 2 – Verify Interface Status

Checked:

- VLAN 20 interface up on OpenWrt
- No interface errors
- Correct gateway (10.10.20.1)

Conclusion: L3 interface functioning.

---

### Step 3 – Test Local VLAN Reachability

From a device statically configured in VLAN 20:

- Unable to ping 10.10.20.1
- ARP table incomplete

Conclusion: Traffic not reaching gateway.

---

### Step 4 – Inspect Trunk Configuration

Reviewed trunk ports between:

- Zyxel GS1920 ↔ OpenWrt
- Zyxel GS1920 ↔ Cisco SG300

Findings:

- VLAN 20 allowed on Zyxel trunk
- VLAN 20 missing from SG300 trunk allowed list

Traffic was not being propagated across switches.

Root issue: VLAN 20 was not tagged across one trunk link.

---

## 6. Root Cause

Misaligned trunk configuration between Zyxel GS1920 and Cisco SG300.

VLAN 20 was defined on both switches but was not included in the trunk’s allowed VLAN list on one side.

Result:

- DHCP broadcast never reached OpenWrt
- No ARP resolution
- Complete isolation of VLAN 20

---

## 7. Resolution

Actions taken:

- Updated trunk configuration on Cisco SG300
- Explicitly allowed VLAN 20 on trunk port
- Verified tagging consistency (tagged on trunk, untagged on access ports)

After correction:

- DHCP leases successfully assigned
- Gateway reachable
- Internet restored

---

## 8. Validation

Confirmed:

- DHCP working on VLAN 20
- Ping to 10.10.20.1 successful
- Internet connectivity restored
- No impact to other VLANs

Monitored for 15 minutes to confirm stability.

---

## 9. Lessons Learned

- Always validate trunk VLAN allow-lists on both sides
- Do not assume VLAN creation equals VLAN propagation
- Broadcast-based services (DHCP, ARP) are early indicators of trunk failure
- Multi-vendor environments require explicit configuration verification

---

## 10. Preventative Controls Implemented

- Added trunk verification checklist to deployment guide
- Standardized trunk configuration template
- Implemented post-change validation checklist:
  - DHCP test per VLAN
  - Gateway reachability
  - Cross-switch VLAN audit