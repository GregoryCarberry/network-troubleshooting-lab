# HH5A-AP1 OpenWrt Configuration Notes

## Overview
This document captures the base configuration, Wi‑Fi setup, and management-access rules for the HH5A running OpenWrt 21.02.5 in this lab.

The HH5A is used purely as an access point (AP), not a router.

---

## Device Identity
- **Hostname:** `HH5A-AP1`
- **Role:** Dual-band wireless access point
- **LAN Management IP:** `192.168.0.200`
- **Gateway:** `192.168.0.1`
- **DHCP:** Disabled (handled by upstream router)

---

## Wireless Configuration

### 2.4 GHz Radio (radio0)
- **Band:** 2.4 GHz  
- **Channel:** `6`  
- **Country:** GB  
- **Mode:** AP  
- **SSID:** `Lab-Test-2_4G`  
- **Security:** WPA2-PSK (`psk2`)  
- **Key:** `fr0d0452`  
- **HT Mode:** `HT20`  
- **Network:** `lan`

### 5 GHz Radio (radio1)
- **Band:** 5 GHz  
- **Channel:** `36`  
- **Country:** GB  
- **Mode:** AP  
- **SSID:** `Lab-Test-5G`  
- **Security:** WPA2-PSK (`psk2`)  
- **Key:** `fr0d0452`  
- **HT Mode:** `VHT80`  
- **Network:** `lan`

---

## Management Access Rules
- **LAN only (recommended)**  
  LuCI and SSH accessible only via LAN ports.
- **WAN port unused** (disabled or left unconfigured).

Suggested firewall rule:
```
LAN → Device (ACCEPT)
WAN → Device (REJECT)
```

---

## Final `/etc/config/network` (LAN-only, DHCP disabled)
```
config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.0.200'
        option netmask '255.255.255.0'
        option gateway '192.168.0.1'
        option ip6assign '60'

config interface 'wan'
        option device 'dsl0'
        option proto 'pppoe'
```

---

## Final `/etc/config/wireless`
```
config wifi-device 'radio0'
        option type 'mac80211'
        option path 'pci0000:01/0000:01:00.0/0000:02:00.0'
        option band '2g'
        option country 'GB'
        option channel '6'
        option htmode 'HT20'
        option disabled '0'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'Lab-Test-2_4G'
        option encryption 'psk2'
        option key 'fr0d0452'

config wifi-device 'radio1'
        option type 'mac80211'
        option path 'pci0000:00/0000:00:0e.0'
        option band '5g'
        option country 'GB'
        option channel '36'
        option htmode 'VHT80'
        option disabled '0'

config wifi-iface 'default_radio1'
        option device 'radio1'
        option network 'lan'
        option mode 'ap'
        option ssid 'Lab-Test-5G'
        option encryption 'psk2'
        option key 'fr0d0452'
```

---

## Backup Commands

### Backup config
```
sysupgrade -b /tmp/hh5a-ap1-backup.tar.gz
```

### Restore config
```
sysupgrade -r /tmp/hh5a-ap1-backup.tar.gz
```

---

## Checklist for HH5A-AP1
- [x] Static IP set  
- [x] DHCP disabled  
- [x] Wi‑Fi configured (2.4 + 5 GHz)  
- [x] Management locked to LAN  
- [x] Backup taken  

---

