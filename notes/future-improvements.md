# Future Improvements

Planned enhancements and stretch goals for the Network Troubleshooting Lab.

## Automation
- Scripts to automatically introduce and revert specific faults (e.g. disable DHCP, change VLANs, tweak routes).
- Wrapper script to spin up “Scenario N” and display instructions.
- Use Ansible or simple SSH scripts to push configs to OpenWRT and the switch.

## Monitoring and Visibility
- Add a lightweight metrics stack (Prometheus + Grafana or similar) to visualise:
  - Latency to key endpoints
  - Packet loss over time
  - Interface utilisation
- Export switch counters via SNMP for basic monitoring practice.

## Wireless Scenarios
- Integrate Cisco APs fully into the lab.
- Create Wi-Fi SSIDs mapped to different VLANs.
- Simulate:
  - Guest vs internal Wi-Fi
  - AP isolation issues
  - Wrong VLAN on SSID causing “Wi-Fi only” problems.

## Security / Hardening
- Add scenarios for:
  - Rogue DHCP server detection
  - Open Wi-Fi vs WPA2/WPA3
  - Basic firewall hardening on OpenWRT
- Experiment with port security and MAC limiting on the switch.

## Additional Services
- Host small web apps or APIs on the Linux server to emulate real business services.
- Add a simple DNS zone for internal hostnames and test split-horizon DNS behaviour.
- Introduce an internal-only subnet that is reachable only via specific routes.

## Documentation and Case Studies
- Expand the `/scenarios` folder with more detailed, interview-ready case studies.
- Add before/after config snippets and packet captures for each scenario.
- Include example troubleshooting notes in the style of an incident ticket.

## Homelab Expansion
- Optionally add virtual machines for multiple client OS types.
- Test VPN access into the lab from outside the LAN.
- Experiment with containerised services (Docker) behind NAT.

## Notes
This list is intentionally aspirational. Items will be ticked off as they are implemented and tested in the lab.
