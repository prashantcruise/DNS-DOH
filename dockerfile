
# --------------------------------------------------
# Builder
# --------------------------------------------------
FROM alpine:3.22 AS builder

ARG TARGETARCH
ARG DNSCRYPT_VERSION=2.1.20

RUN apk add --no-cache ca-certificates tar wget

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
    test -x "linux-${ARCH}/dnscrypt-proxy"; \
    install -m 0755 "linux-${ARCH}/dnscrypt-proxy" /tmp/dnscrypt-proxy; \
    /tmp/dnscrypt-proxy -version


# --------------------------------------------------
# Runtime
# --------------------------------------------------
FROM alpine:3.22

LABEL maintainer="Prashant Kumar"
LABEL description="DNSCrypt Proxy with DoH and ODoH support"

RUN apk add --no-cache \
    ca-certificates \
    bind-tools \
    tzdata \
    && update-ca-certificates \
    && addgroup -S dnsuser \
    && adduser -S -G dnsuser dnsuser \
    && mkdir -p /config \
    && chown -R dnsuser:dnsuser /config

COPY --from=builder /tmp/dnscrypt-proxy /usr/local/bin/dnscrypt-proxy

COPY --chown=dnsuser:dnsuser dnscrypt-proxy.toml /config/dnscrypt-proxy.toml
COPY entrypoint.sh /entrypoint.sh

RUN chmod 0755 /entrypoint.sh \
    && chmod 0755 /usr/local/bin/dnscrypt-proxy

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV TZ=Asia/Kolkata

USER dnsuser

EXPOSE 5053/tcp
EXPOSE 5053/udp

HEALTHCHECK --interval=60s --timeout=5s --start-period=30s --retries=3 \
    CMD-SHELL dig +time=3 +tries=1 @127.0.0.1 -p 5053 cloudflare.com A +short | grep -Eq '^[0-9]+\.' || exit 1

ENTRYPOINT ["/entrypoint.sh"]
