# Network Troubleshooting Lab – Pre‑Build Checklist

This checklist is for preparing the home lab *before* you start running any of the troubleshooting scenarios.  
It focuses on making sure hardware, cabling, addressing and base configs are all in a sane, known state.

---

## 1. Hardware inventory

Confirm you physically have:

- Core network
  - Virgin Media hub (primary Internet router)
  - Powerline pair (PC ⇄ Virgin hub)
  - **Zyxel GS1900-24** managed switch (main switch + lab core)
  - “Dumb” unmanaged switch (optional — keep for future scenarios, not used in steady-state)
  - **BT Home Hub 5A** running OpenWrt 21.02.5 (lab access point `HH5A-AP1`)
- **Hosts**
  - Main Windows 10 PC (VS Code, WSL/Ubuntu)
  - Linux Lite box (Pentium 3805U, 8 GB RAM) for lab host / tools
  - Raspberry Pi (Pi OS Lite, SSH enabled) – optional extra host
- **Cabling & power**
  - Enough Cat5e/Cat6 patch leads for:
    - Virgin hub ⇄ powerline
    - Powerline ⇄ GS1900-24
    - GS1900-24 ⇄ HH5A-AP1
    - GS1900‑24 ⇄ lab hosts (PC / Linux Lite / Pi)
  - IEC “kettle” leads for GS1900‑24 and any other mains‑powered gear
  - Spare patch leads for scenario injections
- **Console / management**
  - Working USB‑to‑RS232 adapter and DB9 extension (for legacy gear, kept for reference)
  - SSH client (Windows: PuTTY or OpenSSH; Linux: `ssh` CLI)
  - Web browser (for GS1900 web UI and LuCI if needed)

Tick everything off **before** moving on.

---

## 2. Base addressing plan

Use a simple, home‑friendly plan tied to the existing Virgin hub LAN.

- **Home LAN** (Virgin hub):
  - Subnet: `192.168.0.0/24`
  - Gateway/Router: `192.168.0.1`
  - DHCP range: leave at Virgin default (e.g. `192.168.0.10–192.168.0.254`) or tighten later.
- **Static management IPs (outside “normal” DHCP range if you tighten it):**
  - HH5A‑AP1 (OpenWrt): **`192.168.0.200`**
  - GS1900‑24: **`192.168.0.210`** (to be set when the switch arrives)
- **DNS**
  - For the lab, clients can keep using whatever DNS the Virgin hub hands out.
  - Later scenarios may override DNS (e.g. pointing at a Linux DNSmasq instance).

Make sure `192.168.0.200` is reachable now (HH5A already configured) before you start touching anything else.

---

## 3. Physical patching – “steady state”

The GS1900-24 becomes the main switch for both normal daily use AND all lab scenarios.

Steady-state cabling:

1. Core path
   - Virgin hub LAN port → Powerline adapter A
   - Powerline adapter B → **GS1900-24 (port 1)**

2. Lab + home devices into GS1900-24
   - GS1900-24 port 2 → Main PC
   - GS1900-24 port 3 → HH5A-AP1 (LAN1)
   - GS1900-24 port 4 → Linux Lite box
   - GS1900-24 port 5 → Raspberry Pi (optional)

3. Optional equipment
   - The dumb switch remains available but **is not used** unless a scenario explicitly calls for it (loops, STP failure, unknown untagged networks, etc.).

Ensure link LEDs come up on GS1900-24 for every connected device before continuing.

---

## 4. Software prerequisites on the PC

On the Windows 10 PC (with WSL/Ubuntu) make sure you have:

- **Git & repo**
  - Git installed in WSL
  - This repo cloned to `~/network-troubleshooting-lab`
- **Basic tools in Ubuntu**
  - `ping`, `traceroute`, `tcpdump`, `nmap`, `curl`, `dig` / `nslookup`
- **Python (for scripts)**
  - Python 3 and `pip` available
- **VS Code**
  - WSL integration working
  - Recommended extensions: Markdown, YAML, Bash, Python

You don’t need anything fancy yet – just the basics so the scripts and notes in this repo are usable.

---

## 5. Known‑good connectivity checks

With the “steady state” cabling in place:

1. From **Windows** (PowerShell):
   - `ping 192.168.0.1` → Virgin hub responds.
   - `ping 192.168.0.200` → HH5A‑AP1 responds.
2. From **WSL/Ubuntu**:
   - `ping 192.168.0.1`
   - `ping 192.168.0.200`
3. From **HH5A‑AP1 (SSH into 192.168.0.200)**:
   - `ping 192.168.0.1` (default gateway)
   - `ping 8.8.8.8` (Internet reachability) – optional
4. Once the **GS1900‑24** is online and given `192.168.0.210`:
   - `ping 192.168.0.210` from PC and from HH5A‑AP1.

If any of these fail, fix the base network first. There’s no point trying scenarios on a broken foundation.

---

## 6. Lab “ground rules”

To keep scenarios repeatable:

- **No ad‑hoc changes** on HH5A‑AP1 or the GS1900‑24 that aren’t captured in:
  - `configs/openwrt/*.txt`
  - `configs/switch/*.txt`
- Before each scenario:
  - Re‑apply the **base configs** for HH5A‑AP1 and GS1900‑24.
  - Confirm the **known‑good connectivity checks** still pass.
- After each scenario:
  - Either roll back to the base config, or commit the “broken” config separately in Git under a clear branch / tag.

That way the repo always represents exactly what’s running in the lab (or how to get back to it).

---

## 7. What’s next?

Once this pre‑build is done and stable:

1. Apply the **HH5A‑AP1 base config** (bridged AP, dual‑band SSIDs, no DHCP).
2. Apply the **GS1900‑24 base config** once the switch arrives (management IP, VLANs, STP basics).
3. Start working through the scenarios under `scenarios/` one at a time.

If anything in this checklist doesn’t match reality later (for example, you change addressing), update this file *and* the relevant configs so everything stays in sync.
