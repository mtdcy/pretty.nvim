#!/bin/bash
# setup a remote socket for coping text back
set -eo pipefail
cd "$(dirname "$0")"

SSH_SOCKET=${SSH_SOCKET:-8643}

if ! pgrep -f "ncopyd.sh" > /dev/null 2>&1; then
    echo "start copyd ..."
    ./pretty.copyd.sh &
    sleep 1
fi

IFS=' ' read -r _ LOCAL_SOCKET < /tmp/copyd.pid || true
LOCAL_SOCKET=${LOCAL_SOCKET:-$SSH_SOCKET}

ssh -t -R "$SSH_SOCKET:localhost:$LOCAL_SOCKET" "$@" \
    "export SSH_SOCKET=$SSH_SOCKET; exec \$SHELL -li"
