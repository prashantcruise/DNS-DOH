FROM alpine:3.22

LABEL maintainer="Prashant Kumar"

RUN apk add --no-cache \
    dnscrypt-proxy \
    ca-certificates \
    bind-tools \
    tzdata \
 && mkdir -p /config

COPY dnscrypt-proxy.toml /config/dnscrypt-proxy.toml
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 5053/tcp
EXPOSE 5053/udp

HEALTHCHECK --interval=120s --timeout=10s --start-period=30s --retries=3 \
CMD dig @127.0.0.1 -p 5053 cloudflare.com +short || exit 1

ENTRYPOINT ["/entrypoint.sh"]
