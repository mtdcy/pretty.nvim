#!/bin/bash
# Copy remote text to local pasteboard

COPYD_LISTEN_PORT=${COPYD_LISTEN_PORT:-9999}

if [ -z "$SSH_RCOPY_PORT" ]; then
    read client _ <<< "$SSH_CLIENT"
    nc -w0 $client $COPYD_LISTEN_PORT 
else
    nc -w0 localhost $SSH_RCOPY_PORT 
fi
