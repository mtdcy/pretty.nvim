#!/bin/bash 
# setup a remote socket for coping text back
set -e 
cd $(dirname $0)

SSH_SOCKET=${SSH_SOCKET:-10000}

if ! pgrep -f "pretty.copyd.sh" > /dev/null 2>&1; then
    echo "start copyd ..."
    ./pretty.copyd.sh &
    sleep 1
fi

IFS=' ' read _ LOCAL_SOCKET < /tmp/pretty.copyd.pid

ssh -t -R "$SSH_SOCKET:localhost:$LOCAL_SOCKET" "$@" " \
    export SSH_SOCKET=$SSH_SOCKET; \
    exec \$SHELL -li \
    "
