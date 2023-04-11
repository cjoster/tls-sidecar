#!/bin/sh

set -euo pipefail

exec >&2

echo "Environment variable \"HTTP_PORT\" is set to \"${HTTP_PORT:=80}\"."
echo "Environment variable \"HTTPS_PORT\" is set to \"${HTTPS_PORT:=80}\"."

export HTTP_PORT HTTPS_PORT

envsubst '${HTTP_PORT} ${HTTPS_PORT}' < /etc/nginx/nginx.conf > /tmp/nginx.conf || { >&2 echo "Environment substitution on nginx.conf failed."; exit 1; }
