# Configuration Baselines (Redacted)

This directory contains **sanitised baseline configurations** and templates for devices used in the Network Troubleshooting Lab.

**Important:**
- No passwords, PSKs, keys, community strings, or private identifiers should be committed.
- Device configs here are intended as *reproducible baselines* and *rollback references*, not raw exports.

---

## Current Structure

```
configs/
├── openwrt/                 # OpenWrt baseline templates (router)
│   ├── network-config.txt
│   ├── dhcp-config.txt
│   └── firewall-config.txt
│
├── switching/               # Managed switch baselines (redacted)
│   ├── sg300-28/
│   │   ├── running-config-baseline.redacted.txt
│   │   └── NOTES.md
│   └── zyxel-gs1920-24v1/
│       ├── baseline-notes.md
│       └── export-placeholder.txt
│
├── wireless/                # WLC / WLAN notes (redacted)
│   └── wlc-2504/
│       └── baseline-notes.md
│
├── linux/                   # Test-host / service configs used in scenarios
│   ├── dnsmasq.conf
│   ├── nginx.conf
│   └── static-network-config.md
│
└── archive/                 # Legacy configs kept for reference (sanitised)
    └── hh5a-ap1/
```

---

## Baseline VLAN Model

- VLAN 10 – Trusted (10.10.10.0/24)
- VLAN 20 – IoT (10.10.20.0/24)
- VLAN 30 – Guest (10.10.30.0/24)
- VLAN 99 – Management (10.10.99.0/24)

---

## Redaction Rules

Before committing/exporting configs, remove or replace:

- Usernames / password hashes
- Wi‑Fi PSKs
- SNMP communities
- VPN keys / certificates
- Hostnames that reveal private details (optional)
- MAC addresses (optional; redact if unsure)

Use placeholders like:

- `<REDACTED>`
- `10.10.99.X`
- `AA:BB:CC:DD:EE:XX`

