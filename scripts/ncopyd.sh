#!/bin/bash

set -eo pipefail

# 确保 UTF-8 编码
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

exec 1> >(tee -a "/tmp/ncopyd.log") 2>&1

NCOPYD_PORT=${NCOPYD_PORT:-8643}

if [ "$(uname)" = "Linux" ]; then
    pbcopy="xclip -selection clipboard -encoding UTF-8"
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
