# DNS-DOH

A lightweight Docker image running [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) as a DNS-over-HTTPS (DoH) forwarder, designed to sit behind [Pi-hole](https://pi-hole.net/) for encrypted upstream DNS resolution.

## Architecture

Pi-hole handles local DNS filtering and ad blocking. dnscrypt-proxy handles encrypted, authenticated upstream resolution over HTTPS.

## Upstream Resolvers (Failover)

| Server | Provider | Filtering | DNSSEC |
|--------|----------|-----------|--------|
| `cloudflare-family` | Cloudflare 1.1.1.3 | Malware + Adult | ✓ |
| `adguard-dns-family` | AdGuard | Malware + Adult | ✓ |
| `quad9-doh-ip4-filter-pri` | Quad9 | Malware | ✓ |
| `quad9-doh-ip4-filter-alt` | Quad9 (alt) | Malware | ✓ |

dnscrypt-proxy uses a `p2` (Weighted Power of Two) load balancing strategy — it continuously probes all resolvers, routes to the fastest, and automatically fails over if one goes down.

## Security Features

- **DoH only** — DNSCrypt and ODoH disabled
- **DNSSEC required** — drops responses without valid signatures
- **No-log servers only** — `require_nolog = true`
- **Filtering servers only** — `require_nofilter = false`
- **TLS session tickets disabled** — enforces Perfect Forward Secrecy
- **Restricted cipher suites** — ECDHE + AEAD only (TLS 1.2/1.3)
- **Blocked query types** — `ANY`, `HINFO`, `NAPTR`, `SRV`, `SSHFP`, `TLSA`
- **Bootstrap leak prevention** — `ignore_system_dns = true`
- **Unqualified query blocking** — stops `.local`/single-label leaks
- **Non-root container** — runs as `dnsuser`

