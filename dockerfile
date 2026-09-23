
FROM alpine:3.22 AS builder

ARG TARGETARCH
ARG DNSCRYPT_VERSION=2.1.18

RUN apk add --no-cache \
    ca-certificates \
    tar \
    wget

WORKDIR /tmp

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) ARCH="x86_64" ;; \
      arm64) ARCH="arm64" ;; \
      arm) ARCH="arm" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    URL="https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${DNSCRYPT_VERSION}/dnscrypt-proxy-linux_${ARCH}-${DNSCRYPT_VERSION}.tar.gz"; \
    wget -O dnscrypt-proxy.tar.gz "${URL}"; \
    tar xzf dnscrypt-proxy.tar.gz; \
    install -m 0755 "linux-${ARCH}/dnscrypt-proxy" /tmp/dnscrypt-proxy


# Runtime image
FROM alpine:3.22

LABEL maintainer="Prashant Kumar"

RUN apk add --no-cache \
    ca-certificates \
    bind-tools \
    tzdata \
    && update-ca-certificates \
    && mkdir -p /config

COPY --from=builder /tmp/dnscrypt-proxy /usr/local/bin/dnscrypt-proxy

COPY dnscrypt-proxy.toml /config/dnscrypt-proxy.toml
COPY entrypoint.sh /entrypoint.sh

RUN addgroup -S dnsuser \
    && adduser -S -G dnsuser dnsuser \
    && chown -R dnsuser:dnsuser /config \
    && chmod 0755 /entrypoint.sh \
    && chmod 0755 /usr/local/bin/dnscrypt-proxy

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

USER dnsuser

EXPOSE 5053/tcp
EXPOSE 5053/udp

HEALTHCHECK --interval=120s --timeout=10s --start-period=30s --retries=3 \
    CMD dig @127.0.0.1 -p 5053 cloudflare.com +short | grep -qE '[0-9a-fA-F:]' || exit 1

ENTRYPOINT ["/entrypoint.sh"]
