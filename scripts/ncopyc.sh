#!/bin/bash
# Copy remote text to local pasteboard

set -eo pipefail

# 确保 UTF-8 编码
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

NCOPYD_PORT=${NCOPYD_PORT:-$SSH_SOCKET}
NCOPYD_PORT=${NCOPYD_PORT:-8643}

if [ -z "$SSH_SOCKET" ] && [ -n "$SSH_CLIENT" ]; then
    IFS=' ' read -r client _ <<< "$SSH_CLIENT"
else
    client=localhost
fi

if [ -f "$*" ]; then
    cat "$@" | nc -w0 "$client" "$NCOPYD_PORT"
elif [ -n "$*" ]; then
    printf '%s' "$@" | nc -w0 "$client" "$NCOPYD_PORT"
else
    # read from pipe
    nc -w0 "$client" "$NCOPYD_PORT"
fi
