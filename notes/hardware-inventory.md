# Hardware Inventory

Structured inventory of all devices used in the Network Troubleshooting Lab.

## Core Network Devices

### 1. Virgin Hub
- Role: Upstream internet gateway / main home router
- Location: Downstairs
- LAN IP: 192.168.0.1
- DHCP: Enabled (main LAN)
- Notes: Provides internet and primary home network.

### 2. BT Hub (OpenWRT)
- Role: Lab router / router-on-a-stick
- Location: Upstairs
- OS: OpenWRT
- WAN: DHCP from Virgin Hub
- LAN: (Planned) 192.168.50.1/24 for lab subnet
- Services: DHCP, routing, firewall/NAT
- Notes: Primary flexible router for the lab.

### 3. Allied Telesyn AT-8326GB
- Role: Managed lab switch
- Model: AT-8326GB
- Ports: 24x 10/100 + uplink
- Management: RS-232 console + IP (planned)
- Features: VLANs, STP, port mirroring
- Notes: Central to VLAN and switching scenarios.

### 4. HiPoint 8-Port Unmanaged Switch
- Role: Existing upstairs distribution switch
- Type: Dumb/Unmanaged
- Notes: Used for day-to-day connectivity; can be repurposed as needed.

### 5. Powerline Adapters
- Role: Link between upstairs lab and downstairs Virgin Hub
- Notes: Introduces realistic latency/jitter; can be part of test scenarios.

## Servers and Hosts

### 6. Linux Workstation
- Role: Lab server + diagnostic host
- OS: Linux (WSL host + native Linux box)
- Services (planned):
  - DNS (dnsmasq or similar)
  - Web server (NGINX)
  - SSH
  - Monitoring scripts (latency, reachability)
- Notes: Primary box for running tests and hosting services.

### 7. Windows PC
- Role: Daily driver + lab client
- OS: Windows 10
- Tools:
  - PowerShell
  - Wireshark
  - SSH client
- Notes: Used to simulate end-user/client behaviour and run Windows-specific tools.

### 8. NAS
- Role: Storage + optional lab service target
- Notes: Can be used as a ping/SMB/HTTP target in scenarios.

### 9. Raspberry Pi (Model B)
- Role: Fault injection / test endpoint
- OS: (Planned) Lightweight Linux / Raspbian
- Uses:
  - Static IP misconfigs
  - DNS/gateway mistakes
  - Service testing (e.g. small web server)
- Notes: Ideal for “broken device” scenarios.

## Wireless Equipment

### 10. Cisco Access Points
- Role: Wi-Fi network for wireless troubleshooting
- Uses (planned):
  - SSID/VLAN mapping tests
  - Wi-Fi vs Ethernet behaviour
  - AP isolation / roaming
- Notes: Controlled via console/SSH; integrated after core lab is stable.

## Legacy / ISP Routers

### 11. Technicolor TG582n (x4)
- Role: Locked ISP routers for realistic NAT/DHCP fault scenarios
- Limitations: No OpenWRT; limited config
- Uses (planned):
  - DHCP conflicts
  - Double-NAT scenarios
  - Misconfigured DNS/DHCP tests

### 12. Technicolor DWA0120
- Role: Additional ISP router for testing
- Limitations: Locked firmware
- Uses (planned):
  - Bridge/AP mode tests (where possible)
  - Double-NAT and routing quirks

## Cables and Console Access

### Serial / Console
- USB to RS-232 adapter (PL2303-based)
- DB9 female-to-female straight-through RS232 extension
- Used for: Console access to Allied Telesyn AT-8326GB

### Ethernet
- Multiple Cat5e/Cat6 patch cables of various lengths
- Notes: Can be swapped to simulate cable issues.

## Notes
- This inventory will be updated as devices are added, repurposed, or removed.
- Some values (IPs, VLAN IDs, etc.) are “planned” until the lab configuration is finalised.
