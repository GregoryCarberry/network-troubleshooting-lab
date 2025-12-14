# HH5A-AP1 (BT Home Hub 5A) — OpenWrt Access Point Configuration

## Overview

This directory documents the configuration and troubleshooting process used to repurpose a **BT Home Hub 5A (HH5A)** running **OpenWrt 21.02** as a **wired access point and Layer‑2/Layer‑3 boundary** within the home network troubleshooting lab.

The HH5A is **not acting as the primary router**. Instead, it provides:

- Wired and wireless LAN access
- VLAN-aware switching
- DHCP (LAN-side)
- NAT and forwarding towards an upstream router
- A realistic “ISP CPE downstream device” scenario for lab work

This README captures the *final known‑good state*, the mistakes encountered along the way, and the reasoning behind each fix.

---

## Final Topology

```
Internet
   │
Virgin Media Hub (modem mode)
Management IP: 192.168.100.1
   │
   ▼
BT Home Hub 5A (HH5A‑AP1) — OpenWrt
LAN: 192.168.0.1/24
WAN: DHCP from Virgin Hub
   │
(powerline)
   │
Cisco SG300 (managed switch)
   │
PC / Lab devices
```

Key point: **The HH5A is the routing and DHCP boundary for the lab LAN.**

---

## Virgin Media Hub (VHub) Notes

- Virgin Hub is in **modem mode**
- Management IP **192.168.100.1** remains reachable *by design*
- This is normal behaviour for Virgin hardware
- No further configuration is required once modem mode is enabled

Nothing is “wrong” if you can still access `192.168.100.1` via Ethernet.

---

## HH5A Role and Design

### Interfaces

| Interface | Purpose |
|---------|--------|
| `eth0.1` | LAN (VLAN 1) |
| `eth0.2` | WAN (VLAN 2) |
| `br-lan` | Bridge containing LAN + WLAN |
| `wlan0 / wlan1` | 2.4GHz / 5GHz APs |

The HH5A uses a **VLAN-aware internal switch**, so correct tagging is critical.

---

## VLAN Configuration (HH5A)

### VLAN Table (OpenWrt Switch)

| VLAN | CPU | LAN Ports | WAN |
|----|----|-----------|-----|
| 1 (LAN) | tagged | untagged | off |
| 2 (WAN) | tagged | off | untagged |
| 99 (mgmt) | tagged | off | off |

Important:
- CPU port **must be tagged** for all VLANs
- LAN devices expect **untagged VLAN 1**
- WAN must be isolated from LAN

---

## Bridge Configuration

```
br-lan members:
- eth0.1
- wlan0
- wlan1
```

Verified via:

```
brctl show
ip link show eth0.1
```

This confirms VLAN 1 traffic is correctly bridged.

---

## DHCP Configuration (Critical Fix)

### The Problem

LAN clients could:
- Ping the router
- Resolve DNS via the router
- NOT reach the internet

Root cause:
```
dhcp.lan.ignore='1'
```

DHCP was explicitly disabled.

### Fix

```
uci set dhcp.lan.ignore='0'
uci commit dhcp
/etc/init.d/dnsmasq restart
```

After this:
- Clients received correct IP, gateway, DNS
- End‑to‑end connectivity restored

---

## Firewall Configuration (Critical Fix)

### The Problem

LAN traffic was **not forwarded to WAN**, even though WAN connectivity worked from the router itself.

### Fix

Ensure forwarding exists:

```
uci set firewall.@forwarding[-1].src='lan'
uci set firewall.@forwarding[-1].dest='wan'
uci commit firewall
/etc/init.d/firewall restart
```

Confirmed by successful:
- `ping 8.8.8.8` from PC
- `curl https://example.com`
- Normal browser access

---

## Cisco SG300 Notes

- Uplink port connected to HH5A operates as **access port (VLAN 1)**
- No trunking required for this scenario
- VLAN mismatch on uplink will break connectivity silently

Lesson learned:
> When troubleshooting, always verify whether the *uplink* is access or trunk before touching IP config.

---

## Verification Checklist

From a LAN client:

- ✅ `ping 192.168.0.1`
- ✅ Receives DHCP lease in `192.168.0.0/24`
- ✅ DNS resolution works
- ✅ `ping 8.8.8.8`
- ✅ `curl https://example.com`
- ✅ Browser loads external sites

From the HH5A:

- ✅ WAN receives DHCP address
- ✅ Can ping external IPs
- ✅ Firewall forwarding active

---

## Files in This Directory

| File | Description |
|----|------------|
| `hh5a-working-config.tar.gz` | Known‑good full config backup |
| `network.conf` | OpenWrt network configuration |
| `wireless.conf` | Wi‑Fi configuration |
| `firewall-config.txt` | Firewall rules snapshot |
| `dhcp-config.txt` | DHCP configuration snapshot |
| `network-config.txt` | Network UCI dump |
| `hh5a-ap1-notes.md` | Raw troubleshooting notes |
| `README.md` | This document |

---

## Restore Procedure

To restore the working configuration:

```
sysupgrade -r hh5a-working-config.tar.gz
```

(Use with care — overwrites current config.)

---

## Lessons Learned

- VLAN mistakes look like routing failures
- DHCP `ignore=1` will ruin your day
- DNS working ≠ internet working
- Always confirm **LAN → WAN forwarding**
- Managed switches add power *and* ambiguity

---

## Status

✅ **Stable, working**
✅ **Documented**
✅ **Repo‑ready**
