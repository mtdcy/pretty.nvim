#!/bin/bash

COPYD_LISTEN_PORT=${COPYD_LISTEN_PORT:-9999}

pbcopy="pbcopy" 
netstat="netstat -anp tcp"   # macOS
if [ "$(uname)" = "Linux" ]; then
    pbcopy="xclip -selection clipboard"
    netstat="netstat -tnl"
fi

# find out available port
while true; do
    $netstat | grep -w "$COPYD_LISTEN_PORT" > /dev/null 2>&1 || break
    COPYD_LISTEN_PORT=$(( COPYD_LISTEN_PORT + 1))
done

echo "start copyd $$ @ $COPYD_LISTEN_PORT" 
echo "$$ $COPYD_LISTEN_PORT" > /tmp/pretty.copyd.pid

while true; do
    nc -l "$COPYD_LISTEN_PORT" | $pbcopy 
done
