# Scenario 01 – DHCP Failure on Baseline LAN

## Overview

A client on the **baseline home/lab LAN (192.168.0.0/24)** cannot obtain an IP
address via DHCP. This simulates a very common real-world incident where a user
reports “no internet” or “limited connectivity” on a wired or Wi‑Fi device.

This scenario uses your **actual baseline topology**:

- Virgin Media hub: main router + DHCP server (`192.168.0.1`)
- GS1900-24: core switch (all ports untagged in VLAN 1)
- HH5A-AP1: OpenWrt access point (AP‑only, static IP `192.168.0.200`)
- Clients: main PC, Linux Lite host, Wi‑Fi devices

There is **no separate lab subnet** or router yet – this is deliberately simple
and real-world.

---

## Topology (Simplified)

```text
Internet
   │
Virgin Media Hub (192.168.0.1, DHCP on)
   │
 Powerline pair
   │
GS1900-24 (core switch, VLAN 1 only)
   ├── Port 2 → HH5A-AP1 (192.168.0.200, AP mode, DHCP off)
   ├── Port 3 → Main PC
   ├── Port 4 → Linux Lite host
   └── Port 5 → Raspberry Pi (optional)
```

DHCP behavior in baseline:

- **Virgin hub** is the only DHCP server.  
- All wired and wireless clients should receive a `192.168.0.x` lease with:
  - Gateway: `192.168.0.1`
  - DNS: typically `192.168.0.1` (or whatever the Virgin hub hands out).

---

## Symptoms

Pick one client to be “broken” (e.g. Linux Lite host on port 4, or the main PC).
That client shows one or more of:

- No IPv4 address at all
- An APIPA address (169.254.x.x)
- A static address someone left on the NIC (e.g. 192.168.1.x)
- No default gateway configured
- Can’t ping `192.168.0.1` (Virgin hub)
- Can’t ping `192.168.0.200` (HH5A-AP1)
- User reports “no internet” / “limited connectivity”

---

## Possible Root Causes (Deliberate Faults to Introduce)

You can choose any of these as the **actual root cause** for the scenario.  
The diagnostic workflow remains mostly the same.

1. **DHCP disabled on Virgin hub**
   - Hub misconfigured or DHCP turned off.

2. **Client interface misconfigured**
   - Static IP on wrong subnet (e.g. 192.168.1.x or /16 mask).
   - Manually configured DNS/gateway that doesn’t exist.

3. **GS1900 port misconfigured**
   - Port accidentally removed from VLAN 1.
   - Port admin‑down.
   - Storm control or security feature blocking traffic (for later scenarios).

4. **Bad cabling / powerline issue**
   - Powerline link down or unstable.
   - Client patched into the wrong port (physically).

5. **Rogue DHCP server on the lab host (advanced variant)**
   - Linux Lite or Pi running its own DHCP server handing out conflicting leases.

For the **first run**, keep it simple: pick **one** fault only, e.g.
“client NIC has a static 192.168.1.x address” or “DHCP disabled on hub”.

---

## Reproduction Steps (Lab)

### Option A – Misconfigured client NIC (simple)

1. On the **main PC** or Linux Lite host, manually set:
   - IP: `192.168.1.50`
   - Mask: `255.255.255.0`
   - Gateway: `192.168.1.1` (nonexistent)
2. Disconnect and reconnect the cable or disable/re-enable the adapter.
3. Confirm:
   - No internet access.
   - Pings to `192.168.0.1` fail.
   - `ipconfig` / `ip a` shows the wrong subnet.

### Option B – DHCP disabled on Virgin hub (requires hub admin)

1. Log in to the Virgin hub web UI.
2. Disable DHCP on the LAN interface.
3. Release IP on the client:
   - Windows: `ipconfig /release`
   - Linux: `sudo dhclient -r`
4. Renew IP:
   - Windows: `ipconfig /renew`
   - Linux: `sudo dhclient`
5. Client should now get:
   - No lease (no IP), **or**
   - An APIPA address `169.254.x.x`.

Only use this option if you’re comfortable temporarily affecting the whole LAN.
Otherwise, stick with Option A (client-only fault).

---

## Diagnostic Workflow

### 1. Check the Client

#### On Windows
```powershell
ipconfig /all
```
Questions:
- Does the client have an IPv4 address?
- Is it in `192.168.0.0/24` or somewhere else (192.168.1.x, 169.254.x.x)?
- Does it have a default gateway (`192.168.0.1`)?
- Does DNS look sane?

#### On Linux
```bash
ip a
ip route
cat /etc/resolv.conf
```
Questions:
- Is the interface `UP`?
- Does it have a `192.168.0.x`/24 address?
- Is the default route via `192.168.0.1`?
- Which DNS server is configured?

### 2. Check Physical & Switch Port

- Are link LEDs lit on:
  - The NIC?
  - The corresponding GS1900 port?
- On the GS1900 web UI:
  - Confirm the port is **up**, in **VLAN 1**, and not admin‑disabled.
  - Check port statistics for errors (high error counts → bad cable/port).

If moving the client to another known-good port (e.g. swap ports 3 and 4)
immediately fixes the issue, suspect:

- Cable
- Port
- Per-port configuration

### 3. Verify DHCP Behaviour

Pick a working client (if any) and the broken one, and compare:

#### On Linux (either host)
```bash
sudo tcpdump -i <iface> port 67 or port 68 -n
```
Then renew IP on the broken client and watch for:

- `DHCPDISCOVER` from the client
- `DHCPOFFER` from the Virgin hub (source IP `192.168.0.1`)

If you see **DISCOVERs but no OFFERs**, suspect:

- DHCP is disabled on the hub
- The switch uplink (port 1) is down or in the wrong VLAN

If you see **OFFERs but the client still has no IP**, suspect:

- Client misconfiguration (static, firewall, service issues).

### 4. Check the Virgin Hub (if suspected)

From any working client:

- Browse to the hub UI (`http://192.168.0.1`).
- Verify DHCP is **enabled**.
- Check its DHCP range and leases.
- Confirm it still lists the broken client’s MAC in the lease table (if any).

If DHCP is disabled or the pool is exhausted, you’ve found your root cause.

---

## Example Root Cause & Resolution

### Example 1 – Client misconfigured with static IP on wrong subnet

- `ipconfig` shows `192.168.1.50` / 255.255.255.0, gateway `192.168.1.1`.
- No DHCP traffic seen in `tcpdump` (client isn’t even trying).
- Other clients on the same switch port (when swapped) work fine.

**Fix:**

1. Set the NIC back to **DHCP/automatic**.
2. Renew IP:
   - Windows: `ipconfig /release` then `ipconfig /renew`.
   - Linux: `sudo dhclient -r && sudo dhclient`.
3. Confirm the client now has a `192.168.0.x` address and can ping `192.168.0.1`.

### Example 2 – DHCP disabled on Virgin hub

- Broken client shows `169.254.x.x`.
- `tcpdump` shows `DHCPDISCOVER` but **no** reply.
- No devices are receiving new leases.

**Fix:**

1. Re‑enable **DHCP server** on the Virgin hub.
2. On the client, release/renew or reboot.
3. Confirm `192.168.0.x` address obtained and internet access restored.

---

## Lessons Learned

- Always start with the client: IP, gateway, DNS, link status.
- A 169.254.x.x address points to DHCP problems or client misconfig.
- Comparing a **working** and **broken** port or client is extremely powerful.
- Packet capture (even just a few seconds of `tcpdump`) quickly reveals whether
  a DHCP server is responding at all.

---

## Repo Location

This scenario file should live at:

```text
scenarios/01-dhcp-failure.md
```

It is the entry-level scenario and assumes only the **baseline LAN** – no extra
VLANs or lab subnets yet. Later scenarios will build on this and move DHCP into
VLAN‑specific lab networks.
