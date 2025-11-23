# Device & System Configuration

This directory contains configuration files for all components used in the **network-troubleshooting-lab** environment.

## Structure

```
configs/
├── linux/          # Linux-based tools & test hosts
│   ├── dnsmasq.conf
│   ├── nginx.conf
│   └── static-network-config.md
│
├── openwrt/        # OpenWrt-based routers/APs
│   ├── dhcp-config.txt
│   ├── firewall-config.txt
│   ├── network-config.txt
│   │
│   └── hh5a-ap1/   # Device-specific OpenWrt config
│       ├── network.conf
│       ├── wireless.conf
│       └── hh5a-ap1-notes.md
│
└── switch/         # Managed switch configs
    ├── at-8326gb-base-config.txt
    └── at-8326gb-lab-config.txt
```

## Purpose

- **linux/** contains network service configs used for testing or simulating failures.
- **openwrt/** contains templates and device configs for OpenWrt hardware used in the lab.
- **switch/** contains configs for managed switches used in VLAN and routing scenarios.

Each subfolder may include:
- Baseline configs  
- Lab-specific configs  
- Device notes and recovery instructions  

Future devices (e.g., GS1900-24) should follow the same pattern.
