# Lab Changelog

This lab evolves continuously. Changes are intentional and documented.

## 2026-03
- Rewrote Git history to remove sensitive config exports.
- Introduced config tiering: examples / redacted / private.
- Hardened .gitignore to prevent committing secrets.
- Formalised VLAN 10/20/30/99 policy model in README.

## 2026-02
- Introduced management VLAN (99).
- Centralised routing authority on OpenWrt.
- Migrated switching to pure Layer 2 model.
- Integrated Cisco WLC 2504 with trunked AP deployment.

## Ongoing
- Refining least-privilege access to VLAN 99.
- Evaluating hardware changes without discarding older gear.