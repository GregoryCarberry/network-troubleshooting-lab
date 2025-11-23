# GS1900-24 Baseline Configuration Guide

## Overview
This guide prepares a new or reset Zyxel GS1900-24 switch for use in the network‑troubleshooting lab.

The configuration focuses on:
- Stable management access  
- Secure defaults  
- Lab‑friendly VLAN groundwork  
- CLI-first reproducibility  
- Avoiding features that cause confusion (Loop Guard, DHCP Snooping, etc.)

---

## 1. Device Identity & Management IP

### Settings
- **Hostname:** `GS1900-24-LAB1`
- **Management IP:** `192.168.0.210`
- **Subnet:** `255.255.255.0`
- **Gateway:** `192.168.0.1`
- **DNS:** `192.168.0.1`

---

## 2. Initial Web Login (Required Once)

The GS1900 requires enabling SSH via UI before CLI becomes available.

1. Connect PC → any port on GS1900  
2. Set PC to DHCP or a static `192.168.1.x` address  
3. Browse to:  
   ```
   http://192.168.1.1
   ```
4. Login (default):  
   - **User:** admin  
   - **Password:** 1234  
5. You’ll be forced to set a new password → choose something lab-safe.

---

## 3. Set Hostname & Management IP (Web UI)

**Menu:**  
```
Basic Setting → IP Setup
```

Set:
- IP: `192.168.0.210`
- Mask: `255.255.255.0`
- Gateway: `192.168.0.1`
- DNS: `192.168.0.1`

Apply → Save.

Reconnect your PC to 192.168.0.x network.

---

## 4. Enable SSH & Secure Management

**Menu:**  
```
Management → Remote Management
```

- **Enable SSH:** ✔  
- **Disable Telnet:** ✔  
- **Enable HTTPS:** ✔  
- **Disable HTTP (optional):** ✔  
- Restrict to VLAN 1 only (default).

Apply → Save.

---

## 5. Disable Unwanted Features

### Disable LLDP-MED (not needed)
```
Advanced Application → LLDP-MED
Uncheck “Enable”
```

### Disable Loop Guard (lab scenarios will rely on STP)
```
Advanced Application → Loop Guard
Disable
```

### Disable storm control (for lab clarity)
```
Advanced Application → Storm Control
Disable
```

Apply → Save.

---

## 6. Prepare VLAN Groundwork

We'll expand VLANs later, but the baseline should include:

| VLAN | Name        | Purpose                | Ports       |
|------|-------------|------------------------|-------------|
| 1    | DEFAULT     | Management LAN         | All untagged|
| 10   | TEST-NET-A  | Scenario A isolation   | None yet    |
| 20   | TEST-NET-B  | Scenario B isolation   | None yet    |

Create them in:
```
Advanced Application → VLAN → Static VLAN Setup
```

Do *not* assign ports yet – that’s scenario-specific.

Save.

---

## 7. Set Port Descriptions (Quality-of-life)

| Port | Label              |
|------|---------------------|
| 1    | Uplink-to-VirginHub|
| 2    | AP1 (HH5A)         |
| 3    | Linux Light Host   |
| 4    | PC                 |
| 5–6  | Pi / optional      |
| 7–24 | Spare              |

**Menu:**  
```
Basic Setting → Port Setup
```

Describing ports dramatically improves troubleshooting during scenarios.

Save.

---

## 8. Save Config Permanently

Zyxel switches *do not* persist changes unless you hit **Save**.

**Menu:**  
```
Management → Configuration → Save
```

Click **Save**.

---

## 9. CLI Equivalent Commands  
(After SSH is enabled)

### Change hostname
```
configure
hostname GS1900-24-LAB1
exit
```

### Set management IP
```
configure
ip address 192.168.0.210 255.255.255.0
ip default-gateway 192.168.0.1
exit
```

### Create VLANs
```
configure
vlan 10
vlan 20
exit
```

### Port descriptions
```
configure
interface ethernet 1 name Uplink-to-VirginHub
interface ethernet 2 name HH5A-AP1
interface ethernet 3 name Linux-Lite-Host
interface ethernet 4 name PC
exit
```

### Save configuration
```
write memory
```

---

## 10. Verification Checklist

Run after the baseline config:

- [ ] SSH reachable at `192.168.0.210`  
- [ ] HTTPS reachable  
- [ ] Hostname correct  
- [ ] VLANs 1/10/20 exist  
- [ ] Port names correct  
- [ ] Switch shows correct time  
- [ ] Config saved persistently  

---

## File Purpose

This file should live in:

```
configs/switch/gs1900-baseline.md
```

It is the *mandatory setup step* before any lab scenario.

