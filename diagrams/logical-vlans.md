# Logical Topology / VLANs (Planned)

VLAN 10 – Lab Clients
- Subnet: 192.168.50.0/24
- Gateway: 192.168.50.1 (OpenWRT)
- Usage: Primary wired clients in the lab.

VLAN 20 – Test / Isolated
- Subnet: 192.168.60.0/24 (example)
- Gateway: 192.168.60.1 (OpenWRT)
- Usage: Misconfig / isolation scenarios.

VLAN 30 – Management (Optional)
- Subnet: 192.168.70.0/24 (example)
- Gateway: 192.168.70.1 (OpenWRT)
- Usage: Switch/router management interfaces.

Trunk: AT-8326GB <-> OpenWRT
- Carries VLANs: 10, 20, 30
- Native VLAN: (to be decided and documented)
