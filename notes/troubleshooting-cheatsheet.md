# Troubleshooting Cheatsheet

A quick-reference guide for diagnosing common network issues in a lab or production environment.

## Layer 1 – Physical
- `ip link` – check interface state
- `ethtool <iface>` – link speed/duplex
- Check cables, ports, LEDs
- Test alternative port/cable

## Layer 2 – Switching / ARP
- `ip neigh` – ARP table
- `arp -a` (Windows) – ARP entries
- `brctl show` – bridges (Linux)
- `tcpdump -e` – view MAC-level traffic

## Layer 3 – IP / Routing
- `ip a` – interface IP info
- `ip r` – routing table
- `ping -c 4 <ip>` – basic reachability
- `traceroute <ip>` – path discovery
- `mtr <ip>` – combined ping/trace

## Layer 4 – Transport
- `ss -tulpn` – listening services
- `nc -zv <host> <port>` – port test
- `tcpdump port <X>` – capture packets for a service

## DNS
- `dig <domain>` – full DNS query
- `dig @8.8.8.8 <domain>` – test against known resolver
- `nslookup <domain>`
- Check /etc/resolv.conf

## DHCP
- `sudo dhclient -r && sudo dhclient` – renew lease
- `journalctl -u NetworkManager` – review DHCP logs
- Check DHCP server status, scopes, leases

## NAT
- `sudo iptables -t nat -L -v`
- Test inbound/outbound ports
- Validate gateway routing

## VLANs
- `ip -d link show <iface>` – see VLAN tags
- `tcpdump -i <iface> vlan` – capture VLAN-tagged frames

## Wi-Fi
- `nmcli dev wifi` – scan networks
- Check channel congestion
- Check AP isolation / VLAN assignment

## General Workflow
1. Check link (Layer 1)
2. Check IP + gateway (Layer 3)
3. Check DNS resolution
4. Test service on local machine
5. Test across network
6. Capture traffic if needed
7. Verify routing/NAT
8. Check VLAN membership
9. Review system logs
