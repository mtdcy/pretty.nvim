#!/bin/bash

cd $(dirname "$0") 

install="brew install"
which apt > /dev/null 2>&1 && install="apt install -y" && apt update 

# check_install name
check_install() {
    for name in "$@"; do
        which $name > /dev/null 2>&1 || $install $name 
    done
}
    
check_install git npm python3 neovim

[ -f package.json ] && npm install 
