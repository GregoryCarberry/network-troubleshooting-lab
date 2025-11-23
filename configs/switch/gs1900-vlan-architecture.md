# GS1900-24 VLAN Architecture & Scenario Plan

## 1. Purpose

This document defines the **standard VLAN IDs and their meanings** for the
network-troubleshooting lab when using the Zyxel GS1900-24 as the core switch.

Individual lab scenarios will reference VLANs *by ID and name* based on this
file. That way, scenarios stay consistent even if hardware changes later.

This file does **not** tell you to apply all VLANs at once in production.
Instead, each scenario will say something like:

> "From the base config, apply the Scenario 01 VLAN layout from
> `gs1900-vlan-architecture.md`."

---

## 2. Standard VLANs

These are the VLANs reserved for the lab. You don't have to enable them all at
once, but their **meaning should not change** once adopted.

| VLAN ID | Name        | Purpose                                  | Notes                          |
|--------:|-------------|------------------------------------------|--------------------------------|
| 1       | DEFAULT     | Management + flat LAN (home + lab)       | Existing 192.168.0.0/24        |
| 10      | CLIENTS     | Lab client devices (wired + Wi-Fi)       | DHCP may come from lab box     |
| 20      | SERVICES    | Lab servers (Linux Lite, Pi, etc.)       | DNS/DHCP/web for scenarios     |
| 30      | ISOLATED    | Broken / quarantined segment             | For fault-injection scenarios  |
| 99      | MGMT-ONLY   | Optional future: dedicated management    | Only if/when you split mgmt    |

### 2.1 IP ranges (planned, not enforced yet)

To keep your mental model clean, it's useful to map VLANs to IP ranges even
before you actually spin up routers or DHCP servers for them.

Suggested plan for later:

- VLAN 1 – DEFAULT / home LAN: `192.168.0.0/24` (existing Virgin hub LAN)
- VLAN 10 – CLIENTS: `192.168.10.0/24`
- VLAN 20 – SERVICES: `192.168.20.0/24`
- VLAN 30 – ISOLATED: `192.168.30.0/24`
- VLAN 99 – MGMT-ONLY: `192.168.99.0/24` (only if you introduce a mgmt VRF/subnet)

> **Important:** Initially, only VLAN 1 is actually routed and has a working
> gateway (the Virgin hub at 192.168.0.1). The other VLANs will come into play
> in scenarios that introduce a lab router or OpenWrt box as an inter-VLAN
> gateway.

---

## 3. Port Role Patterns

Rather than hard-coding ports forever, we define **patterns** and then apply
them differently per scenario.

Baseline physical ports (from the pre-build docs):

| Port | Typical device          |
|------|-------------------------|
| 1    | Uplink to Virgin hub (via powerline) |
| 2    | HH5A-AP1 (OpenWrt AP)   |
| 3    | Main PC                 |
| 4    | Linux Lite host         |
| 5    | Raspberry Pi            |
| 6–24 | Spare lab ports         |

### 3.1 Baseline (no VLAN separation)

The **default, day-to-day** state is:

- All active ports → **untagged in VLAN 1**
- PVID (port VLAN ID) = 1 for all ports
- No tagging, no trunks, everything in the same broadcast domain

This is effectively the same behaviour as an unmanaged switch, but with
management and visibility.

---

## 4. Scenario VLAN Profiles

Each scenario will reference one of these profiles and may tweak a few ports.

### 4.1 Profile A – Basic wired split (Clients vs Services)

**Goal:** Separate lab clients from lab services, but keep everything reachable
via a single router-on-a-stick or OpenWrt box.

Suggested port layout:

| Port | VLAN Mode | Untagged VLAN | Tagged VLANs | Typical device       |
|------|-----------|---------------|--------------|----------------------|
| 1    | Access    | 1             | —            | Uplink to Virgin hub |
| 2    | Access    | 10            | —            | HH5A-AP1 or client   |
| 3    | Access    | 10            | —            | Main PC              |
| 4    | Access    | 20            | —            | Linux Lite (server)  |
| 5    | Access    | 20            | —            | Pi (server)          |
| 6    | Access    | 1             | —            | Spare (home LAN)     |
| 7–24 | Access    | 1             | —            | Spare / default      |

Key points:

- VLAN 1 remains the home LAN.
- VLAN 10 becomes the “client lab” VLAN.
- VLAN 20 holds lab servers.
- A scenario may then introduce:
  - an OpenWrt router with one interface acting as a trunk (VLAN 1/10/20), or
  - a Linux router VM doing inter-VLAN routing.

### 4.2 Profile B – Wi-Fi clients isolated via HH5A

**Goal:** Use HH5A-AP1 as a VLAN-aware AP where SSIDs map to VLANs.

Ports:

| Port | VLAN Mode | Untagged VLAN | Tagged VLANs   | Device       |
|------|-----------|---------------|----------------|--------------|
| 1    | Access    | 1             | —              | Virgin hub   |
| 2    | Trunk     | 1             | 10,20,30       | HH5A-AP1     |
| 3    | Access    | 10            | —              | Main PC      |
| 4    | Access    | 20            | —              | Linux Lite   |
| 5    | Access    | 30            | —              | Pi / victim  |
| 6–24 | Access    | 1             | —              | Spare        |

Concept:

- HH5A-AP1 gets:
  - A “management” SSID or just management IP on VLAN 1 (untagged)
  - A “lab clients” SSID on VLAN 10
  - A “services” SSID on VLAN 20
  - An “isolated/broken” SSID on VLAN 30 (for nasty scenarios)

This profile is **not** the starting point – it requires adding VLAN config on
HH5A as well, so it will be introduced only when a scenario calls for it.

### 4.3 Profile C – Isolated segment for broken hosts

**Goal:** Provide a place to move a misbehaving host where it still has power
and link, but no access to the main LAN.

Example layout:

| Port | VLAN Mode | Untagged VLAN | Tagged VLANs | Device        |
|------|-----------|---------------|--------------|---------------|
| 1    | Access    | 1             | —            | Virgin hub    |
| 2    | Access    | 1             | —            | HH5A-AP1      |
| 3    | Access    | 1             | —            | Main PC       |
| 4    | Access    | 1             | —            | Linux Lite    |
| 5    | Access    | 30            | —            | Isolated host |
| 6–24 | Access    | 1             | —            | Default       |

In this profile, VLAN 30 has **no gateway** and no DHCP by design.  
It’s the “quarantine port”: link comes up, but nothing routes.

---

## 5. How Scenarios Will Use This File

Scenario docs under `scenarios/` will:

- Refer to VLANs **by ID and name** (e.g. “put port 3 into VLAN 10 CLIENTS”).
- Refer to profiles (“Apply Profile A layout to ports 1–5”).
- Include **minimal switch commands** to move from the current state to the
  desired profile, and back.

You should **always restore** the switch to:

- VLAN 1 untagged on all in-use ports  
- No tagged VLANs on access ports  
- Only VLANs 1/10/20/30/99 present in the VLAN table  

…before starting a new scenario, unless the scenario explicitly chains from a
previous one.

---

## 6. Where this file lives

Place this file in:

```text
configs/
  switch/
    gs1900-vlan-architecture.md
```

All future GS1900-related scenario documents assume this file exists and is the
single source of truth for VLAN IDs and their meanings.

