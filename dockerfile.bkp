# syntax=docker/dockerfile:1

FROM alpine:3.18 AS downloader
WORKDIR /tmp

RUN apk add --no-cache curl ca-certificates

# Detect platform and download correct binary automatically
RUN ARCH="$(uname -m)" && \
    case "$ARCH" in \
      x86_64)  BIN_ARCH=amd64 ;; \
      aarch64) BIN_ARCH=arm64 ;; \
      armv7l)  BIN_ARCH=arm ;; \
      armhf)   BIN_ARCH=arm ;; \
      *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    echo "Detected architecture: $BIN_ARCH" && \
    curl -fSL -o /tmp/cloudflared "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${BIN_ARCH}" && \
    chmod +x /tmp/cloudflared

FROM debian:stable-slim AS runner
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /usr/sbin/nologin -M cloudflared

COPY --from=downloader /tmp/cloudflared /usr/local/bin/cloudflared
RUN chown cloudflared:cloudflared /usr/local/bin/cloudflared

COPY --chown=cloudflared:cloudflared entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

USER cloudflared
WORKDIR /home/cloudflared

ENV CLOUDFLARED_OPTS="--address 0.0.0.0 --port 5053"

EXPOSE 5053/udp
EXPOSE 5053/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
