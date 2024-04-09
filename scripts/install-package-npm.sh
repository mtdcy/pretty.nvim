#!/bin/bash

WORKDIR=node_modules 

[ -d $WORKDIR ] || {
    npm init --yes
}

if [ $# -gt 0 ]; then
    npm install --save "$@"
else
    npm install
fi
