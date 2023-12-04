#!/bin/bash

name=pretty-nvim

docker start $name || docker run -itd -v '.:/data' --name $name ubuntu:jammy

sleep 3

docker exec -it $name sh -c 'cd /data && ./install.sh'
