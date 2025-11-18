# Scenario 03 – VLAN Misconfiguration (Client Isolated from Network)

## Overview
A client connected to the lab switch cannot reach the gateway or key services, while other devices on the same physical switch appear fine. This simulates a very common enterprise problem: wrong VLAN on a port or mismatched VLAN configuration.

## Topology (Simplified)

Virgin Hub (192.168.0.1)
   │
   └──> OpenWRT (router-on-a-stick)
            │ (trunk)
            └──> AT-8326GB (managed switch)
                     │ (access port – VLAN X)
                     └──> Client

## Symptoms
- Client has an IP, but:
  - Cannot reach the default gateway
  - Cannot reach other hosts expected to be on the same subnet
  - Cannot reach DNS or the internet
- Other devices on different ports work as expected
- Moving the same client to another port “fixes” the issue

## Possible Root Causes
- Client port assigned to wrong VLAN
- Trunk port missing VLAN in allowed list
- Native VLAN mismatch between switch and router
- Access port configured as trunk (tagged traffic unexpected)
- VLAN deleted or not created on all relevant switches
- Mislabelled patch panel / cables causing patching to wrong port

## Reproduction Steps (Lab)
1. Configure:
   - VLAN 10: Lab clients
   - VLAN 20: Isolated test VLAN
2. Set up OpenWRT with subinterfaces:
   - `ethX.10` → 192.168.50.1/24
   - `ethX.20` → 192.168.60.1/24
3. Configure switch:
   - Trunk uplink to OpenWRT (VLANs 10, 20 allowed)
   - Some ports as access VLAN 10 (normal clients)
   - One port as access VLAN 20 (test/misconfig)
4. Connect a client expecting to be on VLAN 10 into the VLAN 20 port.

## Diagnostic Workflow

### 1. Basic checks on the client
```bash
ip a
ip r
ping -c 4 192.168.50.1   # expected gateway
```

Questions:
- Which subnet is the client actually in?
- Does its IP range match the expected VLAN?

If the client is getting 192.168.60.x instead of 192.168.50.x → strongly suggests wrong VLAN.

### 2. Compare with a known-good port
- Plug the same client into a port you *know* is correct.
- If it works there, the problem is almost certainly switchport config, not the client.

### 3. Inspect VLAN configuration on AT-8326GB
(Example – adjust for actual CLI syntax when we have console access.)

- List VLANs
- Show ports assigned to VLANs
- Confirm the client’s port is in the correct VLAN

Questions:
- Is the port an access port in the intended VLAN?
- Is there any unexpected tagging on the port?

### 4. Check the trunk to OpenWRT
- Confirm the trunk carries the VLAN used by the client.
- Ensure native VLAN expectations are aligned on both sides.
- Make sure VLAN isn’t pruned/filtered on the trunk.

### 5. Optional: use packet capture
On a mirror port:
- Capture ARP and ping traffic from the client.
- Check source IP/MAC and VLAN tags (if visible).
- Validate whether ARP requests are reaching the gateway interface.

## Example Root Case
**Client port assigned to VLAN 20 instead of VLAN 10.**

Observations:
- Client receives 192.168.60.x (VLAN 20 subnet) via DHCP.
- Cannot reach 192.168.50.1 (VLAN 10 gateway).
- Moving client to another port instantly resolves the issue.

## Resolution
1. Change the client switchport to the correct VLAN (e.g. access VLAN 10).
2. Renew client’s DHCP lease:
   - Linux: `sudo dhclient -r && sudo dhclient`
   - Windows: `ipconfig /release && ipconfig /renew`
3. Confirm:
   - Client gets IP in correct subnet (e.g. 192.168.50.x)
   - Can ping gateway and other devices in VLAN 10
   - Has working DNS/internet access (if configured)

## Lessons Learned
- VLAN problems often present as “random” connectivity issues.
- Always compare a broken port with a known-good port.
- IP subnet on the client is a clue to its actual VLAN.
- Trunk misconfiguration can isolate entire VLANs.
- Lab environments are perfect for practising VNAN mistakes *before* they happen in production.
