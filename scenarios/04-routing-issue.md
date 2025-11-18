# Scenario 04 – Routing Issue (Incorrect or Missing Route)

## Overview
A client can reach local devices but cannot reach remote networks (e.g., the internet or another VLAN). This simulates common issues where the default gateway is incorrect, routes are missing, or inter-VLAN routing isn’t configured properly.

## Topology (Simplified)

Virgin Hub (192.168.0.1)
   │
   └──> OpenWRT (192.168.50.1)
            │ (trunk)
            └──> AT-8326GB Switch
                     │
                     └──> Client (192.168.50.x)

## Symptoms
- Client can ping other devices on 192.168.50.x
- Client **cannot** ping 192.168.0.1 (Virgin Hub)
- Client **cannot** reach the internet
- DNS may appear to fail because upstream is unreachable
- `traceroute` stops at the OpenWRT LAN interface

## Possible Root Causes
- Wrong default gateway on client
- Missing static route on OpenWRT
- NAT misconfigured or disabled
- Trunk link missing correct VLAN
- OpenWRT WAN down or wrong interface used
- Routing loop (rare but possible)
- Broken upstream link through powerline adapters

## Reproduction Steps (Lab)
1. Set up working routing:
   - LAN: 192.168.50.0/24 → gateway 192.168.50.1
   - OpenWRT WAN obtains IP from 192.168.0.0/24
2. Break routing intentionally:
   - Remove the default route on OpenWRT
   - Disable NAT / masquerading rules
   - Assign incorrect gateway to client
   - Unplug WAN cable or disable interface

## Diagnostic Workflow

### 1. Check the client’s gateway
Linux:
```bash
ip r
```

Windows:
```powershell
ipconfig
```

Questions:
- Is the default route pointing at 192.168.50.1?
- Does the IP and subnet match expectations?

### 2. Ping the gateway
```bash
ping -c 4 192.168.50.1
```
If this fails → VLAN or L2/L3 issue.
If this succeeds → routing problem is upstream.

### 3. Trace to upstream network
```bash
traceroute 8.8.8.8
```

Useful clues:
- Stalls at 192.168.50.1 → OpenWRT is the problem.
- Stalls before leaving LAN → bad VLAN or gateway.

### 4. Check OpenWRT routing table
```bash
ip r
```

Look for:
- Missing default route (`default via 192.168.0.x dev ethX`)
- Wrong interface
- Routes referencing down interfaces

### 5. Confirm WAN is up
```bash
ifstatus wan
logread | grep -i dhcp
```

### 6. Check NAT rules
```bash
iptables -t nat -L -v
```

Look for a masquerade rule similar to:
```
MASQUERADE  all  --  anywhere  anywhere
```

### 7. Verify trunk configuration
Ensure the lab VLAN is allowed across the switch uplink to OpenWRT.

### 8. Optional packet capture
On OpenWRT:
```bash
tcpdump -i eth0.10 icmp or port 53
```
See whether packets from the client are reaching the router.

## Example Root Cause
**NAT disabled on OpenWRT.**

Findings:
- Local LAN works
- Pings to WAN/internet fail
- `iptables -t nat -L` shows no masquerade rule
- Traceroute stops at 192.168.50.1

## Resolution
1. Re-enable masquerading:
   ```bash
   uci set firewall.@zone[1].masq='1'
   uci commit firewall
   /etc/init.d/firewall restart
   ```
2. Confirm:
   - Client can reach 192.168.0.1
   - Client can ping 8.8.8.8
   - DNS now functions normally

## Lessons Learned
- Routing issues often look like DNS or internet outages.
- Always check the default route first.
- NAT is essential for private lab networks.
- Traceroute is one of the quickest tools for spotting routing failures.
