#!/bin/sh
set -e

# If CLOUDFLARED_OPTS is set, pass them; otherwise run with defaults baked into image
if [ -n "$CLOUDFLARED_OPTS" ]; then
  exec /usr/local/bin/cloudflared proxy-dns $CLOUDFLARED_OPTS
else
  exec /usr/local/bin/cloudflared proxy-dns
fi
