#!/bin/bash

set -eo pipefail

exec 1> >(tee -a "/tmp/ncopyd.log") 2>&1

NCOPYD_PORT=${NCOPYD_PORT:-8643}

if [ "$(uname)" = "Linux" ]; then
    pbcopy="xclip -selection clipboard"
    netstat="netstat -tnl"
else
    pbcopy="pbcopy"
    netstat="netstat -anp tcp"
fi

if pgrep "$(basename "$0")"; then
    echo "ncopyd has started"
    exit
fi

echo "start copyd $$ @ $NCOPYD_PORT"

trap "rm -f /tmp/ncopyd.pid" EXIT
echo "$$ $NCOPYD_PORT" > /tmp/ncopyd.pid

while true; do
    nc -l "$NCOPYD_PORT" | $pbcopy || {
        echo "ncopyd failed, exit"
        exit 1
    }
done
