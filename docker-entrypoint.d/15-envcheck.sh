#!/bin/sh

set -euo pipefail

[ -n "${HTTP_PORT:-}" ] || { >&2 echo "FATAL: Envornment variable \"HTTP_PORT\" must be set."; exit 1; } 
[ -n "${HTTPS_PORT:-}" ] || { >&2 echo "FATAL: Envornment variable \"HTTPS_PORT\" must be set."; exit 1; } 

