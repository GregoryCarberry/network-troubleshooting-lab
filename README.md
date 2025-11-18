# Network Troubleshooting Lab

A hands-on lab environment designed to practise real-world network diagnostics, configuration, and fault resolution.  
Built using a mix of enterprise hardware, consumer routers, Linux servers, and a Raspberry Pi used as a “fault injector”.

This environment simulates the types of network problems commonly encountered in service desk, NOC, and junior network engineer roles.

## Goals
- Strengthen troubleshooting skills across Layers 1–7  
- Learn VLANs, routing, DHCP, DNS, switching, NAT  
- Reproduce real network faults and document root cause analysis  
- Build confidence with enterprise switch configuration  
- Prepare for technical interviews (Service Desk, IT Support, Cloud Support)

## Hardware Used
- Allied Telesyn AT-8326GB (managed switch)  
- BT Hub (OpenWRT) – router-on-a-stick  
- Virgin Hub – upstream network  
- Linux workstation – services + diagnostics  
- Raspberry Pi Model B – fault injection device  
- Technicolor TG582n units – NAT/DHCP test devices  
- Cisco Access Points – wireless testing

## Lab Capabilities
- Multi-VLAN segmentation  
- Router-on-a-stick inter-VLAN routing  
- DHCP, DNS, NGINX, SSH, ICMP services  
- STP loop simulations  
- Broadcast/multicast traffic analysis  
- NAT behaviour testing (single and double NAT)  
- Switchport mirroring for Wireshark captures  
- Intentional misconfigurations for training scenarios

## Scenarios (Work In Progress)
Each scenario includes symptoms, diagnostic steps, root cause, and resolution.

- DHCP scope exhaustion  
- DNS failure  
- Wrong subnet mask  
- Incorrect gateway  
- VLAN mismatch  
- Wi-Fi vs Ethernet inconsistencies  
- Routing loops  
- Firewall blocking outbound traffic  
- Double-NAT issues  
- ARP conflicts

## Configurations
All configs stored in the `/configs` folder.

### Switch
- AT-8326GB base config  
- Lab configuration (VLANs, trunks, management IP)

### Router (OpenWRT)
- Network interface config  
- DHCP  
- Firewall / NAT rules

### Linux
- Static route examples  
- NGINX test server  
- dnsmasq lightweight DNS

## Diagnostic Tools Used
- ping, traceroute, ss, ip, tcpdump, dig, nslookup  
- Wireshark  
- Python scripts for latency monitoring  
- Bash scripts for basic checks

## Future Plans
- Automate scenario setup/teardown  
- Add Grafana dashboards  
- Extend wireless testing using Cisco APs

## Status
🟦 Repo structure created  
🟧 Waiting for RS232 console cables  
⬜ Begin documenting scenarios after switch configuration

