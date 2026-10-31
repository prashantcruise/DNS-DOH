#!/bin/sh
set -eux

CONFIG="${DNSCRYPT_CONFIG:-/config/dnscrypt-proxy-odoh.toml}"

echo "Starting dnscrypt-proxy..."
exec dnscrypt-proxy -config "$CONFIG"
