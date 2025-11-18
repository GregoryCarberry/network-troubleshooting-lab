#!/bin/bash
# Simple ping sweep across a /24 subnet.
# Usage: ./ping-sweep.sh 192.168.50

SUBNET=$1

if [ -z "$SUBNET" ]; then
  echo "Usage: $0 <subnet-prefix>"
  echo "Example: $0 192.168.50"
  exit 1
fi

for i in {1..254}; do
  IP="$SUBNET.$i"
  ping -c 1 -W 1 $IP >/dev/null 2>&1 && echo "[+] $IP is alive"
done
