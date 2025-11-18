# Scenario 01 – DHCP Failure on Lab Subnet

## Overview
A client on the lab subnet cannot obtain an IP address via DHCP. This simulates common real-world incidents where users report “no internet” or limited connectivity.

## Topology (Simplified)

Virgin Hub (192.168.0.1) ──> OpenWRT (192.168.50.1) ──> Switch ──> Client

- Virgin Hub: Upstream router
- OpenWRT: Lab router, DHCP for 192.168.50.0/24
- Switch: AT-8326GB (access port on lab VLAN)
- Client: Linux or Windows host on lab VLAN

## Symptoms
- Client shows APIPA address (e.g. 169.254.x.x) or no IP
- `ip a` / `ipconfig` shows no lease from 192.168.50.0/24
- Pings to 192.168.50.1 fail
- User reports “no internet” or “limited connectivity”

## Possible Root Causes
- DHCP server on OpenWRT is disabled
- DHCP scope exhausted or misconfigured
- Wrong VLAN on the switchport (client not in the lab VLAN)
- Incorrect DHCP relay or interface binding
- Upstream link (OpenWRT ↔ switch) down or mispatched
- Firewall blocking DHCP (UDP 67/68)

## Reproduction Steps (Lab)
1. Configure OpenWRT to serve DHCP on 192.168.50.0/24.
2. Confirm a client can get a lease normally.
3. Introduce a fault, for example:
   - Disable DHCP on the lab interface, or
   - Change the VLAN on the client port, or
   - Configure DHCP scope to a very small range and consume it.

## Diagnostic Workflow

### 1. Check the Client
On Linux:
```bash
ip a
nmcli dev show <iface>
```

On Windows:
```powershell
ipconfig /all
```

Questions:
- Does the client have an IP?
- Is it in 192.168.50.0/24 or APIPA (169.254.x.x)?
- Does it have a gateway and DNS?

### 2. Test Link and VLAN
- Check link lights on switch and NIC.
- On switch: verify the port is in the correct VLAN (lab VLAN).
- If you move the client to a known-good port and it works, suspect VLAN or port config.

### 3. Check DHCP Server (OpenWRT)
On OpenWRT (SSH):

```bash
# Check running services
ps | grep dnsmasq

# Check DHCP config
cat /etc/config/dhcp

# View logs (depending on OpenWRT version)
logread | grep -i dhcp
```

Questions:
- Is the DHCP service running?
- Is the correct interface configured for DHCP?
- Is the address pool sensible (e.g. 192.168.50.100–192.168.50.200)?

### 4. Check for Conflicting DHCP Servers
From the client, run a packet capture during renewal:

```bash
sudo tcpdump -i <iface> port 67 or port 68 -n
```

Look for:
- `DHCP Discover` / `Offer` traffic
- Multiple servers responding
- No response at all from expected server

### 5. Verify Upstream Connectivity
- Ping OpenWRT LAN IP (192.168.50.1) from another working host on same VLAN.
- If that fails, check switch uplink port and VLAN tagging.

## Example Root Cause
**DHCP disabled on OpenWRT LAN interface.**

- Client shows 169.254.x.x
- No `DHCP Offer` packets seen in `tcpdump`
- `dnsmasq` not running or misconfigured

## Resolution
1. Re-enable DHCP on the correct interface in OpenWRT.
2. Restart the DHCP service:
   ```bash
   /etc/init.d/dnsmasq restart
   ```
3. On the client, renew lease:
   - Linux: `sudo dhclient -r && sudo dhclient`
   - Windows: `ipconfig /release && ipconfig /renew`
4. Confirm the client receives an IP from 192.168.50.0/24 and can ping 192.168.50.1 and the internet.

## Lessons Learned
- Always confirm Layer 1/2 first (link, VLAN).
- Use packet capture to see if DHCP traffic actually exists.
- Verify that the DHCP server is bound to the correct interface and subnet.
- Misconfigured DHCP is a very common, high-impact but easily preventable fault.
