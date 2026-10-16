# DNS-DOH

A lightweight Docker image running [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) as a DNS-over-HTTPS (DoH) forwarder, designed to sit behind [Pi-hole](https://pi-hole.net/) for encrypted upstream DNS resolution.

## Architecture

Pi-hole handles local DNS filtering and ad blocking. dnscrypt-proxy handles encrypted, authenticated upstream resolution over HTTPS.

## Upstream Resolvers

Resolvers are loaded from the maintained public DoH and ODoH resolver lists.
dnscrypt-proxy uses a `p2` (Power of Two Choices) load-balancing strategy to
probe resolvers, prefer faster healthy servers, and fail over when one is
unavailable. ODoH resolvers are routed through a compatible ODoH relay selected
from the maintained relay list.

## Security Features

- **Encrypted upstreams** — DoH and ODoH enabled; DNSCrypt disabled
- **DNSSEC required** — drops responses without valid signatures
- **No-log servers only** — `require_nolog = true`
- **No-filter servers only** — `require_nofilter = true`; Pi-hole remains the filtering layer
- **TLS session tickets disabled** — enforces Perfect Forward Secrecy
- **Restricted cipher suites** — ECDHE + AEAD only (TLS 1.2/1.3)
- **Bootstrap leak prevention** — `ignore_system_dns = true`
- **Unqualified query blocking** — blocks single-label and undelegated/reserved TLD queries
- **Non-root container** — runs as `dnsuser`
