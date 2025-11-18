# Scenario 02 – DNS Outage / DNS Misconfiguration

## Overview
A client on the lab network cannot resolve domain names. Connectivity to IP addresses works, but hostnames fail. This simulates common real‑world issues like “internet not working” when the underlying problem is DNS only.

## Topology (Simplified)

Virgin Hub (192.168.0.1)
   │
   └──> OpenWRT (192.168.50.1 – DNS forwarder)
            │
            └──> Switch (lab VLAN)
                     │
                     └──> Client

## Symptoms
- Client cannot load websites by hostname (e.g. `google.com`)
- IP-based access works (e.g. `ping 8.8.8.8`)
- DNS lookups time out or return errors
- Applications report “No internet connection” despite connectivity

## Possible Root Causes
- Wrong DNS server handed out by DHCP
- DNS server on OpenWRT is down (dnsmasq not running)
- Upstream DNS unreachable (Virgin Hub or external resolver)
- Firewall blocking DNS (UDP/TCP 53)
- Client DNS cached incorrectly
- Wrong DNS suffix / search domain
- VLAN misconfig causing DNS to be unreachable

## Reproduction Steps (Lab)
1. Confirm normal DNS working on lab subnet.
2. Introduce controlled fault:
   - Stop dnsmasq on OpenWRT
   - Change DHCP DNS option to invalid server
   - Point client to a non‑existent DNS server
   - Block port 53 on the firewall
   - Disconnect OpenWRT WAN

## Diagnostic Workflow

### 1. Test direct connectivity
```bash
ping -c 4 8.8.8.8
```
If this works → Layer 3 is fine.

### 2. Test DNS resolution
```bash
dig google.com
nslookup google.com
```
Note error messages:
- SERVFAIL
- NXDOMAIN
- Timeout

### 3. Check the client's DNS configuration
Linux:
```bash
resolvectl status
cat /etc/resolv.conf
nmcli dev show <iface> | grep DNS
```

Windows:
```powershell
ipconfig /all
```

### 4. Check DHCP options from OpenWRT
```bash
cat /etc/config/dhcp | grep dns
```

### 5. Validate DNS service on OpenWRT
```bash
ps | grep dnsmasq
logread | grep -i dns
/etc/init.d/dnsmasq restart
```

### 6. Packet capture to confirm DNS failing
```bash
sudo tcpdump -i <iface> port 53 -n
```
Look for:
- DNS queries leaving client
- No replies, malformed replies, or replies from wrong server

## Example Root Cause
**DHCP handing out invalid DNS server (192.168.50.123 instead of 192.168.50.1).**

Findings:
- Client receives wrong DNS via DHCP
- Pings work by IP
- DNS queries time out
- OpenWRT logs show no DNS traffic arriving

## Resolution
1. Correct DNS setting in OpenWRT DHCP config:
   ```bash
   uci set dhcp.lan.dhcp_option='6,192.168.50.1'
   uci commit dhcp
   /etc/init.d/dnsmasq restart
   ```
2. Renew client’s DHCP lease.
3. Confirm:
   - `dig google.com` works
   - Browser loads sites normally
   - Packet capture shows valid DNS query/response

## Lessons Learned
- DNS outages often look like full internet outages to end users.
- Always test IP connectivity separately.
- DHCP DNS options are a common failure point.
- Packet captures quickly reveal whether DNS replies exist.
- Misconfigured DNS is one of the most common real‑world support issues.
