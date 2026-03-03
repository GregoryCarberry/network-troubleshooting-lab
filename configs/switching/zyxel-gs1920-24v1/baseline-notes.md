# Zyxel GS1920-24v1 Baseline Notes

The Zyxel GS1920 is managed primarily via web UI.

## Recommended Baseline Artifacts to Store (Redacted)

- VLAN table (10/20/30/99)
- Port membership matrix (tagged/untagged)
- Trunk port definitions
- Management IP on VLAN 99 (10.10.99.X)
- Any STP / loop prevention settings used in the lab

## Export Guidance

If you export a config from the UI, review it for:
- admin usernames
- password hashes
- SNMP community strings
- device serial numbers (optional)

Store the exported file here as:
- `running-config.redacted.txt` (or similar)

