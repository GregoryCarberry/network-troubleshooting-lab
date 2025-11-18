#!/bin/bash
# Fault injector script for Raspberry Pi

case "$1" in
  break-gateway)
    echo "Breaking default gateway..."
    sudo ip route del default
    ;;
  break-dns)
    echo "Breaking DNS..."
    echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
    ;;
  break-ip)
    echo "Assigning wrong static IP..."
    sudo ip addr flush dev eth0
    sudo ip addr add 10.123.45.67/24 dev eth0
    ;;
  fix)
    echo "Restoring DHCP..."
    sudo dhclient -r
    sudo dhclient
    ;;
  *)
    echo "Usage: $0 {break-gateway|break-dns|break-ip|fix}"
    ;;
esac
