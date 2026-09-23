#!/bin/sh
set -eu

CONFIG=/config/dnscrypt-proxy.toml

case "${DNS_SERVER:-doh_filter}" in
    doh_filter)
        SERVERS="
cloudflare-family
adguard-dns-family
quad9-doh-ip4-filter-pri
quad9-doh-ip4-filter-alt
"
        ;;

    doh)
        SERVERS="
cloudflare
adguard-dns
quad9-doh-ip4-pri
quad9-doh-ip4-alt
"
        ;;

    *)
        echo "ERROR: Unknown DNS_SERVER=${DNS_SERVER}"
        exit 1
        ;;
esac

SERVER_NAMES=$(printf '%s\n' "$SERVERS" | awk '
    BEGIN { first=1; printf "server_names = [" }
    NF {
        if (!first) printf ", "
        printf "'\''%s'\''", $1
        first=0
    }
    END { print "]" }
')

echo "DNS_SERVER=${DNS_SERVER:-doh_filter}"
echo "$SERVER_NAMES"

sed -i "/^server_names =/d" /config/dnscrypt-proxy.toml

sed -i "1i\\$SERVER_NAMES" /config/dnscrypt-proxy.toml

echo "Starting dnscrypt-proxy..."

exec dnscrypt-proxy -config "$CONFIG"
