#!/bin/bash

set -e

cd $(dirname "$0")

# cleanup
#rm -rf py3env node_modules package-lock.json nvim.appimage nvim-macos*
# always remove py3env as interpretor is hardcoded in venv
rm -rf py3env

RED="\\033[31m"
info() { echo -e "$RED$*\\033[39m"; }

# Host prepare
pkg=''
if which brew >/dev/null 2>&1; then
    pkg="$(which brew)"
elif which apt >/dev/null  2>&1; then
    if [ $(id -u) -eq 0 ]; then
        apt update
        pkg="apt -y"
    else
        sudo apt update
        pkg="sudo apt -y"
    fi
    $pkg install libfuse2
else
    info "== Fixme, unsupported platform..."
fi

if [ -z "$pkg" ]; then
    echo "FIXME: please add support for $(lsb_release -d | awk -F: '{ print $2 }')"
    exit 1
fi

# install host tools 
for i in curl git python3 npm; do
    which $i || $pkg install $i
done
python3 -m ensurepip --upgrade || $pkg install python3-pip python3-venv

# speed up by mirrors 
if [ ! -z "$MIRRORS" ]; then
    #pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    #npm  config set registry https://registry.npmmirror.com 
    pip3 config set global.index-url $MIRRORS/pypi/simple
    npm  config set registry $MIRRORS/npmjs
fi

# nvim setup
# install nvim
INSTDIR="${INSTDIR:-$HOME/.local/bin}"
[ -d "$INSTDIR" ] || mkdir -pv "$INSTDIR"
if [ "$(uname -s)" = "Darwin" ]; then
    if [ ! -e nvim-macos/bin/nvim ]; then
        curl -LO https://github.com/neovim/neovim/releases/download/v0.9.4/nvim-macos.tar.gz
        tar xzf nvim-macos.tar.gz
        rm nvim-macos.tar.gz
    fi
    ln -svf "$(pwd)/nvim-macos/bin/nvim" "$INSTDIR" || 
        info "== Create symlink for nvim failed, try to link nvim -> $(pwd)/nvim-macos/bin/nvim"
else
    if [ ! -e nvim.appimage ]; then
        curl -LO https://github.com/neovim/neovim/releases/download/v0.9.4/nvim.appimage
        chmod a+x nvim.appimage
    fi
    ln -svf "$(pwd)/nvim.appimage" "$INSTDIR" ||
        info "== Create symlink for nvim failed, try to link nvim -> $(pwd)/nvim.appimage"

    info "== Please make sure you have libfuse2 installed, or try to install with 'apt install libfuse2'."
fi 

# setup nvim config path
if [ "$(pwd)" != "$HOME/.config/nvim" ]; then
    [ -e "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim-$(date)"

    mkdir -p "$HOME/.config"
    ln -svfT "$(pwd)" ~/.config/nvim
fi

# install node modules locally
npm install

# install python modules with venv 
#$pip install neovim cmakelint cmake-format yamllint yamlfix autopep8
python3 -m venv py3env && 
source py3env/bin/activate &&
pip=$(which pip3 2>/dev/null  || which pip) &&
$pip install -r requirements.txt &&
deactivate

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

# nvim final prepare
nvim -c 'packloadall | silent! helptags ALL | UpdateRemotePlugins' +quit
