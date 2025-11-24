# Network Troubleshooting Lab – Deployment Guide

This guide describes how to bring the lab online from a powered-off state to a
stable, known-good baseline that all scenarios can start from.

It assumes you’ve already:

- Flashed and configured **HH5A-AP1** (OpenWrt 21.02.5) as an access point
  with IP `192.168.0.200`.
- Reset and baseline-configured the **GS1900-24** switch as per:
  - `configs/switch/gs1900-baseline.md`
  - `configs/switch/gs1900-vlan-architecture.md`
- Updated the **pre-build checklist**:
  - `notes/pre-build-checklist.md`

---

## 1. Physical Topology (Baseline)

### 1.1 Core layout

From WAN to lab:

- Virgin Media hub (router + DHCP @ `192.168.0.1`)
- Powerline pair (between Virgin hub and lab room)
- GS1900-24 managed switch (core switch)
- HH5A-AP1 as dual-band AP
- Lab hosts (PC, Linux Lite, Raspberry Pi)

### 1.2 Cabling

Recommended port mapping on the GS1900-24:

- **Port 1 → Powerline adapter** (uplink to Virgin hub)
- **Port 2 → HH5A-AP1 LAN1**
- **Port 3 → Main PC**
- **Port 4 → Linux Lite box**
- **Port 5 → Raspberry Pi** (optional)
- **Ports 6–24 → Spare**

In the baseline state:

- All active ports are **untagged members of VLAN 1**.
- PVID = 1 for all ports.

---

## 2. Power-On Sequence

This sequence reduces “mystery failures” from race conditions or DHCP oddities.

1. **Power on Virgin Media hub**  
   - Wait until WAN and LAN LEDs are stable.

2. **Power on both powerline adapters**  
   - Confirm the powerline “link”/“pair” LED is solid (not blinking in error).

3. **Power on the GS1900-24**  
   - Check that:
     - Port 1 LED (uplink) lights when the powerline is connected.
     - SYS/STATUS LED shows normal operation (not flashing error codes).

4. **Power on HH5A-AP1**  
   - Ensure LAN LED (for the port connected to GS1900) is lit.
   - Wait for Wi-Fi LED to come on.

5. **Power on lab hosts** (PC, Linux Lite, Pi)  
   - Verify link/activity LEDs on relevant GS1900 ports.

---

## 3. Baseline Network State

Once powered:

- Virgin hub:
  - IP: `192.168.0.1`
  - DHCP: enabled (default range is fine for now)
- GS1900-24:
  - Management IP: `192.168.0.210`
  - Default gateway: `192.168.0.1`
  - VLANs: at minimum, VLAN 1 present, all ports untagged in VLAN 1
- HH5A-AP1:
  - IP: `192.168.0.200` (static)
  - Gateway: `192.168.0.1`
  - DHCP: disabled
  - SSIDs:
    - `Lab-Test-2_4G` (2.4 GHz, WPA2-PSK `fr0d0452`)
    - `Lab-Test-5G` (5 GHz, WPA2-PSK `fr0d0452`)

---

## 4. Verification from the Main PC

On Windows (PowerShell):

```powershell
ipconfig
```

You should see:

- An IPv4 address in `192.168.0.x` (from Virgin hub DHCP)
- Default gateway: `192.168.0.1`

Then:

```powershell
ping 192.168.0.1      # Virgin hub
ping 192.168.0.200    # HH5A-AP1
ping 192.168.0.210    # GS1900-24
```

All three should respond.

From WSL/Ubuntu on the same PC:

```bash
ping -c 4 192.168.0.1
ping -c 4 192.168.0.200
ping -c 4 192.168.0.210
```

If any of these fail, fix the base connectivity before attempting lab scenarios.

---

## 5. Verification from HH5A-AP1

SSH into the AP:

```bash
ssh root@192.168.0.200
```

Then:

```bash
ping -c 4 192.168.0.1      # Virgin hub
ping -c 4 192.168.0.210    # GS1900-24
ping -c 4 8.8.8.8          # Optional – Internet reachability
```

You should also confirm that a wireless client:

1. Connects to `Lab-Test-2_4G` or `Lab-Test-5G` with `fr0d0452`.
2. Receives a `192.168.0.x` address from the Virgin hub.
3. Can ping `192.168.0.1`, `192.168.0.200`, and `192.168.0.210`.
4. Can reach the Internet (e.g. browse to a website).

---

## 6. Verification from the Linux Lite Box

From the Linux Lite host (wired to GS1900 port 4):

```bash
ip a
```

You should see an IPv4 address in `192.168.0.x` with gateway `192.168.0.1`.

Then:

```bash
ping -c 4 192.168.0.1
ping -c 4 192.168.0.200
ping -c 4 192.168.0.210
```

If this host is going to run services later (DHCP/DNS/HTTP for lab VLANs),
it’s important to confirm it’s stable in the baseline first.

---

## 7. “Known Good” Snapshot

Once all verification steps pass, you are in a **known good baseline**.

At this point you should:

1. **Export GS1900 config**  
   - Use the web UI to download the current configuration and save as:
     - `configs/switch/gs1900-24-base-config.txt`

2. **Backup HH5A-AP1 config**  
   From the AP:

   ```bash
   sysupgrade -b /tmp/hh5a-ap1-backup.tar.gz
   ```

   Then download that file and store it under:

   ```text
   configs/openwrt/hh5a-ap1/hh5a-ap1-backup.tar.gz
   ```

3. Optionally tag a Git commit:
   ```bash
   git add configs/switch/gs1900-24-base-config.txt
   git add configs/openwrt/hh5a-ap1/hh5a-ap1-backup.tar.gz
   git commit -m "Capture known-good baseline configs for GS1900 and HH5A-AP1"
   # Optional:
   # git tag baseline-v1
   ```

---

## 8. Before Starting Any Scenario

Before running a scenario under `scenarios/`:

1. Confirm:
   - PC has `192.168.0.x` and can reach `192.168.0.1/.200/.210`.
   - HH5A-AP1 Wi-Fi is working.
   - GS1900-24 is reachable at `192.168.0.210`.

2. If you’ve done previous experiments:
   - Restore the GS1900 config from `gs1900-24-base-config.txt`.
   - Restore HH5A-AP1 from `hh5a-ap1-backup.tar.gz` if needed.

3. Re-run the quick ping checks in Sections 4–6.

Once all checks pass, you are safe to start a new scenario and deliberately
break things.

---

## 9. File Location

Place this file in the repo as:

```text
notes/lab-deployment-guide.md
```

It is the high-level “bring the whole lab up” document that sits alongside:

- `notes/pre-build-checklist.md`
- `configs/switch/gs1900-baseline.md`
- `configs/switch/gs1900-vlan-architecture.md`
- `configs/openwrt/hh5a-ap1/hh5a-ap1-notes.md`
