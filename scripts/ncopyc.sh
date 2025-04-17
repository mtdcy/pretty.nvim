#!/bin/bash
# Copy remote text to local pasteboard

set -eo pipefail

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
    echo "$@" | nc -w0 "$client" "$NCOPYD_PORT"
else
    # read from pipe
    nc -w0 "$client" "$NCOPYD_PORT"
fi
