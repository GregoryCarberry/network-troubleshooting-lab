# Scenario 05 – STP Loop / Broadcast Storm

## Overview
A switch loop or broadcast storm occurs when two or more switch ports create a Layer 2 loop. This can overwhelm the network with broadcast and multicast traffic, causing massive latency, intermittent connectivity, or complete network failure.

This scenario is extremely realistic—it's one of the most common real-world outages on improperly managed networks.

## Topology (Simplified)

AT-8326GB Switch
   ├── Port 1 → Lab network
   ├── Port 2 → Router trunk
   └── Port 10 → Accidental loop back into Port 11 (or another switch)

## Symptoms
- Very high latency across the LAN
- Clients randomly lose connectivity
- DHCP stops working or becomes extremely slow
- DNS queries fail intermittently
- CPU usage on switch spikes (if visible)
- Wireshark shows:
  - Repeated ARP broadcasts
  - Flooded multicast traffic
  - Duplicate packets
- Link lights may blink rapidly and in sync between the looped ports

## Possible Root Causes
- Two switch ports patched together
- Another switch connected with trunk/access mismatch
- Loop created through powerline adapters or unmanaged switches
- Misconfigured spanning tree (STP disabled)
- Wireless bridging configured incorrectly (client isolation off + bridging)

## Reproduction Steps (Lab)
1. Use two ports on the AT-8326GB.
2. Patch them together using a spare Ethernet cable.
3. Observe within seconds:
   - Latency increases
   - DHCP may fail
   - ARP tables fill rapidly
4. Remove the cable to immediately restore normal operation.

_Note: Keep the loop brief to avoid locking up powerline adapters._

## Diagnostic Workflow

### 1. Observe client behaviour
- Packet loss
- Latency spikes
- Frequent disconnections
- APIPA addresses (DHCP overwhelmed)

### 2. Check switch port activity
Look for:
- Fast-blinking LEDs
- Both ports with identical blink patterns

### 3. ARP table inspection (client)
```bash
ip neigh
```
If ARP entries flap or disappear quickly → strong sign of L2 storm.

### 4. Packet capture (client or mirrored port)
```bash
sudo tcpdump -i <iface> -vv
```
Look for:
- Massive ARP traffic
- Repeated broadcast packets
- Duplicate frames

### 5. Inspect spanning tree on the switch
(Once we have console access.)

Typical checks:
- Is STP enabled globally?
- Is STP enabled on the offending ports?
- Are ports set to “edge” when they should not be?
- Are trunk ports misconfigured?

### 6. Eliminate the loop
- Remove cables one-by-one until symptoms stop.
- Identify the two ports that caused the storm.

## Example Root Cause
**Ports 9 and 10 patched together during cable tidy.**

Observations:
- LAN becomes unusable
- DHCP stops responding
- ARP table floods
- Removing the cable instantly restores network

## Resolution
1. Unplug the loop cable.
2. Verify STP is enabled on:
   - All access ports
   - All trunk ports
3. Mark client-facing ports as STP edge ports (or equivalent).
4. Ensure trunk ports are configured correctly between switches.
5. Document ports and update switch labels.

## Lessons Learned
- Broadcast storms can cripple an entire network in seconds.
- Always enable STP—even in a home lab.
- LED blink patterns can reveal physical loops instantly.
- Powerline adapters and unmanaged switches can propagate loops unexpectedly.
- Packet captures make broadcast storms obvious and easy to diagnose.
