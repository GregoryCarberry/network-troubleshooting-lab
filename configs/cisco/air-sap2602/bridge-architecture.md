# Cisco AIR-SAP2602 Autonomous Wireless Bridge

## Purpose
Extend the wired management VLAN between two physical locations
without running Ethernet, using a point-to-point 5 GHz wireless bridge.

## Hardware
- Cisco AIR-SAP2602I-E-K9 (2x)
- Autonomous IOS 15.2(2)JA

## Design
- One root bridge (AP-1)
- One non-root bridge (AP-2)
- 5 GHz radio (Dot11Radio1)
- Infrastructure-only SSID
- WPA2-PSK with AES
- Transparent Layer-2 bridge (802.1Q capable)

## SSID
- Name: `network-bridge`
- Type: infrastructure-ssid
- Not visible to clients

## Key IOS Requirements (2602-specific)
- `infrastructure-ssid` is mandatory
- Cipher configured under radio, not SSID
- `station-role root bridge` vs `non-root bridge`
- Radio and Ethernet must share a bridge-group
- Parent locking not used to avoid brittleness

## Verification
- `show dot11 associations`
- `show dot11 parent`
- Blue LEDs indicate active bridge

## Outcome
Successfully replaced powerline networking with a stable,
documented wireless Layer-2 bridge.
