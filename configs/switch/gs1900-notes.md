# GS1900-24 Pre-Build Notes

## 1. Scope and role

These notes cover the *initial* setup of the Zyxel **GS1900-24** switch as the main wired core for:

- Normal day-to-day home use
- Network troubleshooting lab scenarios in the `network-troubleshooting-lab` repo

The GS1900-24 replaces the old Allied Telesyn switch in the baseline topology.  
The unmanaged “dumb” switch is **not** used in steady-state, but can still be introduced later for specific scenarios.

---

## 2. Assumptions

- Virgin Media hub remains the main Internet router on **192.168.0.1/24**
- LAN subnet: **192.168.0.0/24**
- Lab devices (current):
  - Main PC
  - Linux Lite box
  - Raspberry Pi (headless)
  - HH5A-AP1 (OpenWrt AP)
- GS1900-24 is a used unit, may have an unknown config → **treat as untrusted until reset**

---

## 3. Target base configuration

### 3.1 Identity

- Hostname: **LAB-SW1**
- Location (if supported): *Home lab – core switch*

### 3.2 Management

- Management IP (VLAN 1):
  - IPv4 address: **192.168.0.210**
  - Netmask: **255.255.255.0**
  - Default gateway: **192.168.0.1** (Virgin hub)
- Management access:
  - HTTP: **disabled** (HTTPS only) if the firmware supports it cleanly
  - HTTPS: enabled on VLAN 1
  - Telnet: **disabled**
  - SSH: enable if supported (preferred), otherwise accept HTTPS-only
  - SNMP: disabled for now (can be enabled explicitly for later monitoring lab)

### 3.3 Time and logs

If available in firmware:

- NTP: use a UK pool (e.g. `0.uk.pool.ntp.org`), or local PC as NTP later
- Timezone: **Europe/London**
- Syslog: leave local-only for now

### 3.4 Switching features

- Spanning Tree Protocol (STP/RSTP): **enabled globally**
- Storm control / broadcast limiting: leave at defaults for now
- Jumbo frames: **disabled** (stick to defaults unless a specific scenario requires them)
- LLDP: enable globally if available (for later topology discovery experiments)

---

## 4. Physical cabling – initial layout

When the switch arrives and is reset:

1. Connect power (IEC “kettle” lead).
2. Cabling (steady-state baseline):
   - Port 1 → Powerline adapter (which goes to Virgin hub)
   - Port 2 → Main PC
   - Port 3 → HH5A-AP1 (LAN1)
   - Port 4 → Linux Lite box
   - Port 5 → Raspberry Pi
3. Confirm link LEDs on ports 1–5 are lit and stable.

This layout matches the `pre-build-checklist.md` baseline and gives you:
- One upstream path to the Internet
- A simple star topology for initial testing
- Room on other ports for lab “problem” devices later

---

## 5. Factory reset and first access

Because the switch is second-hand, first step is **factory reset**.

### 5.1 Physical reset

1. Power on the switch.
2. Hold the RESET button (if present) for the period specified in the manual (typically 5–10 seconds) until status LEDs indicate a reset.
3. Allow the switch to reboot fully.

> If the reset button does nothing, we’ll fall back to discovering the existing IP via `arp -a` and browser, then factory-reset from the web UI.

### 5.2 Direct connection for first login

For the very first login, keep it simple:

1. Disconnect the switch from the rest of the network.
2. Connect **PC ↔ GS1900-24 port 2** directly with an Ethernet cable.
3. On the PC, set a temporary static IP matching the switch’s default subnet
   (commonly something like `192.168.1.10/24` if the switch ships with `192.168.1.1`).
4. Browse to the switch default IP (per label/manual).  
   - Log in with the factory credentials (e.g. `admin` / default password).

Once logged in:

- Change the **admin password** immediately.
- Change the **management IP** to `192.168.0.210/24` with gateway `192.168.0.1`.
- Save/apply and confirm you can still log in at `192.168.0.210` using your temporary static IP on the PC.

### 5.3 Move into steady-state position

1. Revert PC network adapter back to **DHCP**.
2. Patch the switch as per Section 4 (ports 1–5).
3. Confirm from the PC:
   - `ping 192.168.0.210` (GS1900-24)
   - `ping 192.168.0.200` (HH5A-AP1)
   - `ping 192.168.0.1` (Virgin hub)
4. Log into the switch web UI at `https://192.168.0.210` and verify status.

At this point, the switch is in baseline, “boring but stable” mode.

---

## 6. VLAN and lab planning (do NOT apply yet)

We’ll introduce VLANs once the lab is stable. Planned structure (subject to change):

- VLAN 1 – **Mgmt / default** (192.168.0.0/24)
- VLAN 10 – **Clients** (test PCs, Wi-Fi clients)
- VLAN 20 – **Servers / services** (Linux box, Pi)
- VLAN 30 – **Isolated / “broken” segment** for fault-injection scenarios

Planned port roles (once VLANs are implemented):

- Port 1 – Trunk to Virgin hub / router-on-a-stick test device (future)
- Port 2 – Access port (VLAN 10) – main PC by default
- Port 3 – Trunk to HH5A-AP1 (tagged VLANs for SSIDs)
- Port 4 – Access (VLAN 20) – Linux Lite
- Port 5 – Access (VLAN 20 or 30) – Raspberry Pi
- Remaining ports – spare for additional lab hosts, loops, etc.

**Important:** Do **not** configure these VLANs yet.  
They’ll be introduced scenario-by-scenario so each change is traceable and documented in the repo.

---

## 7. Config backup for the repo

Once the above base config is working:

1. Use the GS1900-24 management interface to **export the running/startup config** to a file.
2. Save the file into the repo under:

   ```text
   configs/
     switch/
       gs1900-24-base-config.txt   # exported config
   ```

3. Add a short note to `configs/switch/README.md` describing:
   - Management IP
   - Firmware version
   - Date of the export
   - Any non-default security settings

This gives you a clean, version-controlled “known good” snapshot before we start deliberately breaking things for lab scenarios.
