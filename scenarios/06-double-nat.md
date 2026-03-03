# Incident Scenario: Double NAT Detection and Resolution

## 1. Scenario Summary

Clients experienced connectivity issues with inbound services and certain applications (e.g., port forwarding, VPN, gaming, remote access).

Investigation revealed that the network was operating behind two layers of NAT (Double NAT), caused by the ISP router not being placed in modem mode.

This scenario demonstrates WAN boundary validation and upstream dependency awareness.

---

## 2. Environment Context

Architecture (intended design):

Internet  
→ Virgin Media Hub (Modem Mode)  
→ OpenWrt (NAT + firewall + routing)  
→ VLAN-segmented LAN  

OpenWrt is designed to be the **single NAT boundary**.

---

## 3. Symptoms Observed

- Internet access functional
- DHCP working across VLANs
- Outbound browsing normal
- Inbound port forwarding failing
- VPN server unreachable from external network
- Certain applications reporting “Strict NAT” or connection limitations

No internal VLAN issues observed.

---

## 4. Initial Hypotheses

Possible causes considered:

- Misconfigured port forwarding on OpenWrt
- Firewall blocking inbound traffic
- ISP blocking ports
- WAN IP mismatch
- Double NAT condition

---

## 5. Diagnostic Steps

### Step 1 – Check WAN IP on OpenWrt

On OpenWrt WAN interface:

Observed WAN IP in private range (e.g., 192.168.x.x or 10.x.x.x).

Expected:
- Public routable IP address.

Conclusion:
- OpenWrt not directly exposed to ISP.
- Likely NAT occurring upstream.

---

### Step 2 – Check Virgin Hub Mode

Accessed Virgin Hub management interface.

Observed:
- Router mode enabled
- DHCP active on 192.168.0.0/24
- NAT active

This confirmed OpenWrt was behind another router performing NAT.

---

### Step 3 – External IP Verification

Compared:

- WAN IP on OpenWrt
- Public IP reported by external service (e.g., “what is my IP”)

Mismatch confirmed double NAT:

Internet  
→ Virgin Hub NAT  
→ OpenWrt NAT  
→ LAN

---

## 6. Root Cause

Virgin Media Hub was operating in router mode instead of modem mode.

Result:

- Two NAT layers
- Inbound traffic blocked unless port forwarded on both devices
- UPnP conflicts
- Complicated port forwarding

This created application-layer limitations and made inbound service hosting unreliable.

---

## 7. Resolution

Actions taken:

- Enabled modem mode on Virgin Hub
- Rebooted modem and OpenWrt
- Confirmed OpenWrt WAN interface received public IP
- Revalidated port forwarding rules on OpenWrt

After correction:

- Single NAT boundary restored
- Port forwarding functional
- VPN reachable externally
- Application NAT warnings resolved

---

## 8. Validation

Confirmed:

- WAN interface on OpenWrt shows public IP
- External port scan confirms open forwarded ports
- VPN connection established from external network
- No change to internal VLAN routing or segmentation

---

## 9. Lessons Learned

- Always validate WAN IP against expected public range
- Double NAT is common when using ISP routers
- Inbound services require clear NAT boundary understanding
- WAN troubleshooting starts with IP verification, not firewall assumptions
- Architecture clarity prevents layered complexity

---

## 10. Preventative Controls Implemented

- Documented WAN boundary expectations in deployment guide
- Added WAN IP verification to baseline checklist
- Treated ISP device mode as controlled configuration, not assumption
- Created quick diagnostic rule:
  1. Check WAN IP
  2. Compare with public IP
  3. Confirm modem mode status