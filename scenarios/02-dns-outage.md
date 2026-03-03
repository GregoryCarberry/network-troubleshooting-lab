# Incident Scenario: DNS Resolution Failure

## 1. Scenario Summary

Clients reported “no internet access” despite successful IP assignment and gateway reachability.

Investigation revealed DNS resolution failure while Layer 3 connectivity remained functional.

This scenario demonstrates systematic isolation of application-layer failures from network-layer issues.

---

## 2. Environment Context

Architecture:

- OpenWrt (Layer 3 authority)
  - DHCP
  - DNS (via dnsmasq forwarding)
  - NAT
  - Firewall enforcement
- VLAN segmentation:
  - VLAN 10 – Trusted
  - VLAN 20 – IoT
  - VLAN 30 – Guest
  - VLAN 99 – Management

Clients receive DNS server information via DHCP (OpenWrt).

---

## 3. Symptoms Observed

- Clients connected to Wi-Fi successfully
- DHCP leases assigned correctly
- Gateway reachable (10.10.x.1)
- Unable to access websites via domain name
- Direct IP access (e.g., 8.8.8.8) worked

Example:
- `ping google.com` → failed (unknown host)
- `ping 8.8.8.8` → successful

---

## 4. Initial Hypotheses

Possible causes considered:

- WAN outage
- NAT failure
- Firewall blocking outbound traffic
- DNS forwarding failure on OpenWrt
- Upstream DNS server unreachable
- Incorrect DNS assignment in DHCP scope

---

## 5. Diagnostic Steps

### Step 1 – Confirm Layer 3 Connectivity

Tested:

- Ping default gateway → successful
- Ping external IP (8.8.8.8) → successful
- Trace route to external IP → successful

Conclusion:
- Routing and NAT functioning
- WAN operational

---

### Step 2 – Test DNS Resolution

From client:

- `nslookup google.com`
- `dig google.com`
- `ping google.com`

Results:

- DNS queries timing out
- No A record returned
- Possible "server not responding" error

Conclusion:
- DNS resolution failure confirmed

---

### Step 3 – Validate DHCP DNS Assignment

Checked client configuration:

- DNS server assigned: 10.10.x.1 (OpenWrt)

Verified:

- Client pointing to correct local DNS server

---

### Step 4 – Inspect OpenWrt DNS Service

On OpenWrt:

- Confirmed dnsmasq service status
- Reviewed system logs
- Checked upstream DNS configuration
- Tested DNS resolution locally from router

Findings may include:

- dnsmasq not running
- Misconfigured upstream DNS server
- WAN DNS servers unreachable
- Firewall blocking outbound DNS (UDP/TCP 53)

---

## 6. Root Cause

Root cause identified as:

Example scenarios (one or more may apply depending on test case):

- dnsmasq service stopped or crashed
- Incorrect upstream DNS server configured
- Firewall rule blocking outbound UDP/53
- WAN DNS servers unreachable

The failure was isolated to DNS resolution only; routing and NAT remained functional.

---

## 7. Resolution

Corrective actions taken:

- Restarted dnsmasq service (if service failure)
- Corrected upstream DNS configuration
- Adjusted firewall rules to permit outbound DNS
- Verified WAN DNS reachability

After correction:

- Domain resolution restored
- Browsing functional
- No changes required on client devices

---

## 8. Validation

Confirmed:

- `nslookup google.com` returns valid IP
- `ping google.com` resolves correctly
- Internet browsing restored
- All VLANs tested individually

Monitored for recurrence after fix.

---

## 9. Lessons Learned

- “No internet” does not always mean WAN failure
- Testing IP vs hostname immediately narrows fault domain
- DNS is an application-layer dependency
- Always validate DHCP-assigned DNS server
- Router-local DNS forwarding can become single point of failure

---

## 10. Preventative Controls Implemented

- Added DNS service check to baseline validation checklist
- Documented upstream DNS configuration
- Considered adding secondary upstream DNS provider
- Added quick diagnostic flow:
  1. Ping gateway
  2. Ping external IP
  3. Test DNS resolution