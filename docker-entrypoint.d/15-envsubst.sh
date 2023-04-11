#!/bin/sh

set -euo pipefail

envsubst '${HTTP_PORT} ${HTTPS_PORT}' < /etc/nginx/nginx.conf > /tmp/nginx.conf || { >&2 echo "Environment substitution on nginx.conf failed."; exit 1; }
