# Scenario 06 – Double NAT (Incorrect or Unexpected NAT Chaining)

## Overview
Double NAT occurs when two routers both perform Network Address Translation on traffic going to the internet. This is extremely common in home networks, labs, and small offices where ISP routers are combined with secondary routers.

In this lab, the Virgin Hub performs NAT, and OpenWRT may also be doing NAT. Incorrect routing, DHCP overlap, or misplacement of devices can expose or break double NAT.

## Topology (Simplified)

Internet
   │
   └──> Virgin Hub (192.168.0.1) – NAT #1
             │
             └──> OpenWRT WAN (192.168.0.x)
                    │
                    └──> OpenWRT LAN (192.168.50.1) – NAT #2
                           │
                           └──> Switch → Lab clients (192.168.50.x)

## Symptoms
- Internet works but:
  - Port forwarding fails or is unpredictable
  - Applications complain about “Strict NAT Type” (gaming, VoIP)
  - VPNs behave unreliably or won’t connect
  - Latency increases slightly
- Some internal services unreachable from outside
- Clients get overlapping or unexpected private IP ranges

## Possible Root Causes
- Both Virgin Hub and OpenWRT performing NAT
- Virgin Hub in router mode instead of modem mode
- OpenWRT incorrectly placed behind additional ISP router
- DHCP servers overlapping or misconfigured
- Powerline adapters bridging unintended segments
- Technicolor routers accidentally inserted, causing NAT #3+

## Reproduction Steps (Lab)
1. Keep Virgin Hub in router mode (default).
2. Connect OpenWRT WAN to Virgin Hub LAN.
3. Ensure OpenWRT has NAT enabled.
4. Attempt inbound port forwarding or VPN connection.
5. Observe failures or double translations.

## Diagnostic Workflow

### 1. Check IP addressing on OpenWRT WAN
```bash
ip a | grep eth
```
If WAN is 192.168.0.x and LAN is 192.168.50.x → double NAT confirmed.

### 2. Run traceroute from a lab client
```bash
traceroute 8.8.8.8
```
Typical double NAT behaviour:
- Hop 1 = 192.168.50.1 (OpenWRT LAN)
- Hop 2 = 192.168.0.1 (Virgin Hub)
- Hop 3 = ISP gateway

### 3. Attempt port forwarding test
Use simple tools:
- Online port checkers
- Python HTTP server on client:
  ```bash
  python3 -m http.server 8080
  ```
Forward 8080 on both:
- Virgin Hub → OpenWRT WAN
- OpenWRT → Client

If it fails → double NAT is interfering.

### 4. Check NAT rules explicitly
On OpenWRT:
```bash
iptables -t nat -L -v
```

On Virgin Hub (web UI):
- Check firewall/NAT settings
- Check DMZ or port forwarding rules

### 5. Confirm DHCP isn’t overlapping
Clients should *not* receive 192.168.0.x directly.
If they do:
- VLAN misconfig
- Powerline leakage
- Incorrect switch uplink

### 6. Optional capture of NAT behaviour
```bash
tcpdump -i eth0 port 80 -n
```
Look for translated private IP addresses.

## Example Root Cause
**Virgin Hub left in router mode when OpenWRT also performing NAT.**

Findings:
- Lab client sees double NAT path in traceroute.
- Unable to port forward cleanly.
- VPN disconnections intermittent.

## Resolution Options

### Option A – Put Virgin Hub into Modem Mode
- Virgin Hub stops doing NAT.
- OpenWRT becomes primary router.
- Cleanest, simplest solution.
- Recommended for lab.

### Option B – Disable NAT on OpenWRT
If the Virgin Hub must remain router:
```bash
uci set firewall.@zone[1].masq='0'
uci commit firewall
/etc/init.d/firewall restart
```
OpenWRT then acts as a routed (non-NAT) network.

### Option C – Use DMZ mode
Place OpenWRT into the Virgin Hub’s DMZ:
- Virgin Hub still NATs, but sends all inbound traffic to OpenWRT WAN.
- Slight overhead but workable.

### Option D – Flatten the network
Use OpenWRT in access point mode only (no routing at all).
Not ideal for the lab’s goals but sometimes useful.

## Lessons Learned
- Double NAT is extremely common but often invisible until you need inbound traffic or VPNs.
- Traceroute quickly reveals the NAT chain.
- Port forwarding is difficult across multiple NAT layers.
- Best practice: single NAT wherever possible.
- Labs are ideal for intentionally breaking NAT to understand its behaviour.
