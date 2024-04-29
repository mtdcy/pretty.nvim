#!/bin/bash

name=pretty-nvim-builder

docker stop $name || true
docker rm   $name || true

docker run --rm -it                                  \
    --name $name                                     \
    -v '.:/data'                                     \
    -v '/etc/apt/sources.list:/etc/apt/sources.list' \
    ubuntu:jammy                                     \
    sh -c 'cd /data && ./install.sh'
