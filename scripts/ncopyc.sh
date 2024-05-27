#!/bin/bash
# Copy remote text to local pasteboard

set -eo pipefail

COPYD_PORT=${COPYD_PORT:-$SSH_SOCKET}
COPYD_PORT=${COPYD_PORT:-8643}

if [ -z "$SSH_SOCKET" ] && [ -n "$SSH_CLIENT" ]; then
    IFS=' ' read -r client _ <<< "$SSH_CLIENT"
else
    client=localhost
fi

if [ -f "$*" ]; then
    cat "$@" | nc -w0 "$client" "$COPYD_PORT"
elif [ -n "$*" ]; then
    echo "$@" | nc -w0 "$client" "$COPYD_PORT"
else
    # read from pipe
    nc -w0 "$client" "$COPYD_PORT"
fi
