#!/bin/bash
# Basic diagnostics for connectivity and DNS.

TARGET=${1:-8.8.8.8}
HOST=${2:-google.com}

echo "=== Checking IP configuration ==="
ip a

echo -e "
=== Default route ==="
ip r

echo -e "
=== Ping test to $TARGET ==="
ping -c 4 $TARGET

echo -e "
=== DNS resolution test for $HOST ==="
dig $HOST +short || nslookup $HOST
