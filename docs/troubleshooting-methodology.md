# Troubleshooting Methodology

## Overview

This lab is not designed around random experimentation.

All faults — intentional or accidental — are investigated using a structured methodology designed to:

- Isolate failure domain quickly
- Minimise unnecessary configuration changes
- Separate Layer 2, Layer 3, and application-layer faults
- Produce repeatable diagnostics

---

## Core Principles

1. **Define the scope before touching configuration**
2. **Differentiate L2 vs L3 vs Application**
3. **Test smallest possible domain first**
4. **Change one variable at a time**
5. **Validate after every change**

---

## Fault Domain Isolation Model

### Step 1 – Scope

- Is issue isolated to one VLAN?
- Multiple VLANs?
- Only wireless?
- Only wired?
- Only external connectivity?

Scope defines direction.

---

### Step 2 – Layer Differentiation

Quick triage sequence:

1. Ping gateway (L3 internal)
2. Ping external IP (L3 + NAT)
3. Resolve DNS (Application layer)
4. Test east-west traffic (L2 / VLAN)

This sequence isolates 80% of issues quickly.

---

### Step 3 – Broadcast-Based Services

If DHCP fails:

- Suspect VLAN propagation
- Check trunk allow-lists
- Validate ARP resolution

If DNS fails:

- Test raw IP connectivity
- Check router DNS forwarding

---

### Step 4 – Switch-Side Indicators

Common Layer 2 indicators:

- MAC flapping → possible loop
- High broadcast counters → possible storm
- Single VLAN affected → trunk mismatch

---

### Step 5 – Router-Side Indicators

Common Layer 3 indicators:

- Gateway reachable, but cross-VLAN blocked → firewall
- Router can reach both VLANs → policy issue
- WAN IP private range → double NAT

---

## Validation Model

After every fix:

- Test DHCP
- Test gateway reachability
- Test inter-VLAN policy
- Test internet
- Confirm no regression on unaffected VLANs

No change is considered complete without validation.

---

## Philosophy

The goal is not fast guessing.

The goal is:

- Deterministic isolation
- Controlled remediation
- Post-fix hardening

This approach mirrors real-world infrastructure operations and reduces configuration drift.