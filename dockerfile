FROM alpine:3.22

ARG TARGETARCH
ARG DNSCRYPT_VERSION=2.1.13

LABEL maintainer="Prashant Kumar"

RUN apk add --no-cache \
    ca-certificates \
    bind-tools \
    tzdata \
    wget \
    && mkdir -p /config

# Download dnscrypt-proxy directly from GitHub (gets full latest version)
RUN case "${TARGETARCH}" in \
      "amd64") ARCH="x86_64" ;; \
      "arm64") ARCH="arm64" ;; \
      "arm")   ARCH="arm" ;; \
      *)       ARCH="x86_64" ;; \
    esac \
    && wget -q "https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${DNSCRYPT_VERSION}/dnscrypt-proxy-linux_${ARCH}-${DNSCRYPT_VERSION}.tar.gz" \
    && tar xzf "dnscrypt-proxy-linux_${ARCH}-${DNSCRYPT_VERSION}.tar.gz" \
    && mv "linux-${ARCH}/dnscrypt-proxy" /usr/local/bin/dnscrypt-proxy \
    && rm -rf "dnscrypt-proxy-linux_${ARCH}-${DNSCRYPT_VERSION}.tar.gz" "linux-${ARCH}"

COPY dnscrypt-proxy.toml /config/dnscrypt-proxy.toml
COPY entrypoint.sh /entrypoint.sh

RUN addgroup -S dnsuser && adduser -S -G dnsuser dnsuser \
    && chown -R dnsuser:dnsuser /config \
    && chmod +x /entrypoint.sh

USER dnsuser

EXPOSE 5053/tcp
EXPOSE 5053/udp

HEALTHCHECK --interval=120s --timeout=10s --start-period=30s --retries=3 \
    CMD dig @127.0.0.1 -p 5053 cloudflare.com +short || exit 1

ENTRYPOINT ["/entrypoint.sh"]
