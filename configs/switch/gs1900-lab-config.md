# GS1900-24 – Lab Base Configuration

Target device: **Zyxel GS1900-24** (non‑PoE) smart managed switch.

This document defines the **baseline configuration** used throughout the lab.
Scenario‑specific tweaks (VLANs, port shutdowns, etc.) are applied *on top* of
this base and should always be reverted back to this state when you finish a
scenario.

> Note: The GS1900 series is primarily a **web‑managed** switch. There is a
> limited CLI, but the supported and least‑painful way to configure it is via
> the web UI. The steps below therefore reference the web UI paths rather than
> CLI commands.

---

## 1. Management addressing

We keep everything in the existing home /24 and give the switch a fixed IP in
the “infra” range.

- **Management VLAN**: VLAN 1 (default)
- **IPv4 address**: `192.168.0.210`
- **Subnet mask**: `255.255.255.0`
- **Default gateway**: `192.168.0.1` (Virgin hub)
- **DNS server**: `192.168.0.1` (or any other preferred resolver)
- **Hostname**: `GS1900-24-LAB1`
- **Time zone**: Europe/London, NTP enabled

Management protocols:

- **HTTPS**: enabled
- **HTTP**: disabled (or redirect to HTTPS if firmware supports it)
- **SSH**: enabled (for basic monitoring / future experiments)
- **Telnet**: disabled
- **SNMP**: disabled by default (can be enabled per‑scenario if needed)
- **Remote management from WAN**: disabled (only reachable from the LAN)

---

## 2. Port role plan (base lab topology)

We start with a **flat L2 network**: all active ports are untagged members of
VLAN 1. Later scenarios will introduce extra VLANs and tagging.

Recommended port usage in the home lab:

| Port(s) | Role                                  | Notes                                  |
|--------:|---------------------------------------|----------------------------------------|
| 1       | Uplink to powerline / Virgin hub      | Untagged VLAN 1                        |
| 2       | HH5A‑AP1 (OpenWrt access point)       | Untagged VLAN 1                        |
| 3–6     | Main lab hosts (PC, Linux Lite box, Pi)| Untagged VLAN 1                       |
| 7–10    | Spare lab host ports                  | Untagged VLAN 1                        |
| 11–24   | Free / future expansion               | Leave as default, VLAN 1 untagged      |
| SFP 25–26 | Unused                              | Admin‑down if the firmware allows it   |

Security / hygiene:

- Disable **unused front‑panel LEDs / link tests** if they get annoying.
- If the firmware supports it, **admin‑disable SFP ports** until you actually
  need them.
- Enable **storm control / broadcast limit** at a conservative level once
  you’re comfortable (optional, later tweak).

---

## 3. One‑time initial setup (from factory defaults)

1. **Factory‑reset the switch** (if it’s second‑hand):
   - With power on, press and hold the **RESET** button for ~10 seconds until
     the SYS/STATUS LED indicates a reset (refer to the label/manual).
   - Allow a full reboot (≈ 2–3 minutes).

2. **Directly connect a laptop/PC** to any copper port (e.g. port 24).  
   Disconnect it from the rest of your network while doing this.

3. **Set a temporary static IP** on the PC:
   - IP: `192.168.1.10`
   - Mask: `255.255.255.0`
   - Gateway: `192.168.1.1` (any value inside the /24 will do, this keeps
     Windows happy).

4. **Browse to the default switch IP**:
   - URL: `https://192.168.1.1` (or `http://192.168.1.1` then accept the
     redirect / warning).
   - Default credentials (per Zyxel docs):  
     - User: `admin`  
     - Password: `1234`  
   - Change the admin password immediately to something decent and save it
     in your password manager.

5. **Run the “Getting Start / Start up” wizard** (if offered):
   - Set **Hostname** → `GS1900-24-LAB1`.
   - Set **IP Address** → `192.168.0.210`.
   - Set **Subnet Mask** → `255.255.255.0`.
   - Set **Gateway** → `192.168.0.1`.
   - Set **DNS** → `192.168.0.1` (or 1.1.1.1 / 8.8.8.8, personal choice).
   - Confirm the **time zone** and NTP server(s) (Europe/London).

6. **Apply and SAVE the config**:
   - In Zyxel’s UI you must click the **Save** icon/button at the top bar to
     write the running config to startup. If you forget this step, everything
     disappears on reboot.

7. **Reconfigure your PC back to DHCP** and reconnect it to your main network.

8. Now plug the switch into the real network:
   - Port 1 → existing powerline adapter (which ultimately reaches the Virgin hub).
   - Port 2 → HH5A‑AP1 WAN/LAN (as decided for the lab design).
   - Ports 3–6 → your lab machines (PC, Linux Lite, Raspberry Pi, etc.).

9. From your main PC (on the 192.168.0.0/24 LAN), open:
   - `https://192.168.0.210` and verify you can log in with the new password.

At this point the switch is acting as a **quiet, managed replacement** for the
old dumb switch, with a fixed management IP and sane defaults, but still a
single flat VLAN.

---

## 4. Baseline security & services

From the web UI:

1. **Disable HTTP** or force HTTPS only:
   - *Configuration → System → WWW* (wording may vary by firmware).
2. **Enable SSH**, disable **Telnet**:
   - *Configuration → System → Management → Remote Management*.
3. Verify that only **VLAN 1 IPv4 interface** has an IP address.
4. Optional but recommended later:
   - Configure an **admin read‑only account** for day‑to‑day viewing.
   - Enable **Syslog** to a lab syslog server once you have one.

Keep this base config as the **“known good”** state. When you’re done with a
lab scenario that changes VLANs or ports, revert them so they match the port
plan and behaviour described in sections 1–3 above.
