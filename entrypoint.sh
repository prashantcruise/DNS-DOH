#!/bin/sh
set -eux

CONFIG=/config/dnscrypt-proxy.toml

echo "Starting dnscrypt-proxy..."
exec dnscrypt-proxy -config "$CONFIG"
