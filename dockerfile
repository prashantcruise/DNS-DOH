# syntax=docker/dockerfile:1
######## downloader stage ########
FROM alpine:3.18 AS downloader
ARG ARCH=amd64
WORKDIR /tmp

# curl + ca certs to validate TLS
RUN apk add --no-cache curl ca-certificates

# Download the correct cloudflared binary for requested arch and make it executable
RUN curl -fSL -o /tmp/cloudflared "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}" \
    && chmod +x /tmp/cloudflared

######## runtime stage ########
FROM debian:stable-slim AS runner
LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

# Install ca-certificates so TLS works
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Create a non-root user to run cloudflared
RUN useradd -r -s /usr/sbin/nologin -M cloudflared

# Copy cloudflared binary from downloader stage
COPY --from=downloader /tmp/cloudflared /usr/local/bin/cloudflared
RUN chown cloudflared:cloudflared /usr/local/bin/cloudflared \
 && chmod 0755 /usr/local/bin/cloudflared

# Small entrypoint script that uses CLOUDFLARED_OPTS env var if present
COPY --chown=cloudflared:cloudflared entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

USER cloudflared
WORKDIR /home/cloudflared

# Default env: you can override this when running the container
ENV CLOUDFLARED_OPTS="--address 0.0.0.0 --port 5053"

# Expose port chosen above (adjust if you want 53)
EXPOSE 5053/udp
EXPOSE 5053/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
