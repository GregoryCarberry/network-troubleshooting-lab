# SG300-28 Baseline Notes

This folder contains a **redacted** baseline running-config for the Cisco SG300.

## Redactions Applied

- Local usernames/password hashes removed
- Sensitive strings removed
- Management SVI IP normalised to `10.10.99.X`

## What You Should Still Verify Before Using

- VLAN database contains: 10, 20, 30, 99
- Trunk ports:
  - Allowed VLAN list includes 10,20,30,99
  - Native VLAN decisions are documented (or avoided)
- Management SVI:
  - VLAN 99
  - Correct IP for your environment (replace `10.10.99.X`)

