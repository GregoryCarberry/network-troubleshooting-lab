# Incident Scenario: Inter-VLAN Routing / Firewall Policy Failure

## 1. Scenario Summary

Devices on VLAN 10 (Trusted) were unable to communicate with devices on VLAN 20 (IoT), despite both VLANs having working DHCP and internet access.

The failure was isolated to inter-VLAN communication and traced to firewall policy enforcement on the Layer 3 gateway (OpenWrt).

This scenario demonstrates controlled segmentation and policy debugging.

---

## 2. Environment Context

Architecture:

- OpenWrt (Layer 3 authority)
  - Inter-VLAN routing
  - Firewall enforcement
  - DHCP
  - NAT
- VLAN segmentation:
  - VLAN 10 – Trusted
  - VLAN 20 – IoT
  - VLAN 30 – Guest
  - VLAN 99 – Management

Policy model:

- Trusted → IoT: Allowed (for device management / casting)
- IoT → Trusted: Denied
- Guest → Internal VLANs: Denied

---

## 3. Symptoms Observed

- DHCP functioning on VLAN 10 and VLAN 20
- Internet access working on both VLANs
- Devices on VLAN 10 unable to:
  - Ping devices on VLAN 20
  - Access IoT device web interfaces
- No packet loss within same VLAN
- No WAN outage

Example:

- 10.10.10.x → 10.10.20.x : Timeout
- 10.10.10.x → 8.8.8.8 : Successful

---

## 4. Initial Hypotheses

Possible causes considered:

- Routing failure between VLAN interfaces
- Firewall rule misconfiguration
- Incorrect subnet mask or gateway on IoT device
- Reverse path filtering issue
- NAT interfering with internal routing

---

## 5. Diagnostic Steps

### Step 1 – Confirm Layer 3 Interfaces

On OpenWrt:

- Verified VLAN 10 interface up
- Verified VLAN 20 interface up
- Confirmed correct IP addresses:
  - 10.10.10.1
  - 10.10.20.1

Confirmed router could ping devices in both VLANs individually.

Conclusion:
- Routing engine functional

---

### Step 2 – Test Cross-VLAN Traffic from Router

From OpenWrt:

- Ping VLAN 20 device → Successful
- Ping VLAN 10 device → Successful

Conclusion:
- Inter-VLAN routing working at kernel level
- Issue likely firewall policy

---

### Step 3 – Inspect Firewall Zones

Reviewed:

- Zone assignments for VLAN 10 and VLAN 20
- Forwarding rules between zones
- Default forward policy

Finding:

- Forwarding from VLAN 10 zone → VLAN 20 zone missing
  OR
- Rule present but mis-scoped (wrong source/destination zone)

Traffic was being dropped by firewall before forwarding.

---

### Step 4 – Validate With Temporary Rule

Temporarily:

- Allowed forwarding between VLAN 10 and VLAN 20

Result:

- Immediate restoration of connectivity
- IoT devices accessible from Trusted network

Confirmed firewall was root cause.

---

## 6. Root Cause

Firewall policy misconfiguration on OpenWrt prevented forwarding from VLAN 10 to VLAN 20.

Inter-VLAN routing existed, but forwarding between zones was not permitted.

This was a policy-layer failure, not a routing failure.

---

## 7. Resolution

Actions taken:

- Corrected firewall forwarding rule:
  - Source: VLAN 10 zone
  - Destination: VLAN 20 zone
  - Action: ACCEPT
- Ensured IoT → Trusted remained blocked
- Reloaded firewall configuration

After correction:

- Trusted devices could access IoT devices
- IoT devices remained isolated from Trusted network

---

## 8. Validation

Confirmed:

- VLAN 10 → VLAN 20 ping successful
- IoT device management interfaces reachable
- VLAN 20 → VLAN 10 still blocked
- Guest VLAN isolated from all internal VLANs
- Internet connectivity unaffected

Policy behaviour matches intended segmentation model.

---

## 9. Lessons Learned

- Routing and firewall enforcement are separate layers
- “Cannot reach device” does not automatically mean routing failure
- Testing from router itself isolates policy vs path issues
- Always validate firewall zone-to-zone forwarding explicitly
- Principle of least privilege requires deliberate rule creation

---

## 10. Preventative Controls Implemented

- Added inter-VLAN policy verification to baseline checklist
- Documented intended forwarding matrix
- Added post-change validation:
  - Trusted → IoT test
  - IoT → Trusted block test
  - Guest isolation test

Firewall now treated as intentional policy boundary, not default permissive gateway.