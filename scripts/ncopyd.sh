#!/bin/bash

set -eo pipefail

COPYD_PORT=${COPYD_PORT:-8643}

pbcopy="pbcopy"
netstat="netstat -anp tcp" # macOS
if [ "$(uname)" = "Linux" ]; then
    pbcopy="xclip -selection clipboard"
    netstat="netstat -tnl"
fi

if pgrep "$(basename "$0")"; then
    echo "copyd has started"
    exit
fi

echo "start copyd $$ @ $COPYD_PORT"
echo "$$ $COPYD_PORT" > /tmp/copyd.pid

while true; do
    nc -l "$COPYD_PORT" | $pbcopy || {
        echo "copyd failed, exit"
        exit 1
    }
done
