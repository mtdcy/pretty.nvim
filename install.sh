#!/bin/bash

set -e

cd $(dirname "$0")

# cleanup
#rm -rf py3env node_modules package-lock.json

RED="\\033[31m"
info() { echo -e "$RED$*\\033[39m"; }

# Host prepare
pkg="brew"
if which apt >/dev/null  2>&1; then
    if [ $(id -u) -eq 0 ]; then
        apt update
        pkg="apt -y"
    else
        sudo apt update
        pkg="sudo apt -y"
    fi
fi
$pkg install git python3 npm curl
python3 -m ensurepip --upgrade || $pkg install python3-pip python3-venv

# nvim setup
# install nvim
if [ "$(uname -s)" = "Drawin" ]; then
    curl -LO https://github.com/neovim/neovim/releases/download/v0.9.4/nvim-macos.tar.gz
    tar xzf nvim-macos.tar.gz
    rm nvim-macos.tar.gz
else
    rm -f nvim.appimage || true
    curl -LO https://github.com/neovim/neovim/releases/download/v0.9.4/nvim.appimage
    chmod a+x nvim.appimage
fi
# install node modules
npm install

# install python modules
#$pip install neovim cmakelint cmake-format yamllint yamlfix autopep8
rm -rf py3env || true
python3 -m venv py3env
source py3env/bin/activate
pip=$(which pip3 2>/dev/null  || which pip)
$pip install -r requirements.txt
deactivate

# nvim final prepare
if [ "$(pwd)" != "$HOME/.config/nvim" ]; then
    mkdir -p "$HOME/.config"
    ln -svfT "$(pwd)" ~/.config/nvim
fi

nvim -c 'packloadall | silent! helptags ALL | UpdateRemotePlugins' +quit

# C/C++
if ! which cc; then
    info "== Please install host toolchain 'gcc' or 'clang' for C/C++ support."
fi

# Go
if which go; then
    [ -z "$GOPATH" ] && info "== Please set GOPATH properly" ||
        echo "$PATH" | grep "$GOPATH" || info "== Please add $GOPATH/bin to PATH properly"

    go install golang.org/x/tools/gopls@latest
    go install golang.org/x/tools/cmd/goimports@latest
    # shfmt, author provide new version through go only
    go install mvdan.cc/sh/v3/cmd/shfmt@latest

    # vim-go
    nvim -c 'silent! GoInstallBinaries' +quit
else
    info "== Please install host toolchain 'golang' for Go support"
fi

# Rust
if which rustup; then
    rustup component add rustfmt
else
    info "== Please install host toolchain 'cargo|rustc' for Rust support"
fi

if ! which hadolint; then
    info "** Please install hadolint for Dockerfile support"
fi