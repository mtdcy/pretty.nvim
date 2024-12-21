#!/bin/bash

set -eo pipefail

cd $(dirname "$0")

info() { echo -e "\\033[31m$*\\033[39m"; }

MIRRORS=${MIRRORS:-https://mirrors.mtdcy.top}

# Host prepare
requirements=(curl npm python3)
for x in "${requirements[@]}"; do
    which "$x" || { info "== Please install host tool $x first"; exit 1; }
done

# install node modules locally
npm  config set registry $MIRRORS/npmjs
npm install
# install package with 'npm install <name>' && save with 'npm init'
npm cache clean --force

# install python modules with venv
#  python3.13 has problems to install modules.
if which python3.12; then
    python3.12 -m venv --copies --clear py3env
else
    python3 -m venv --copies --clear py3env
fi

source py3env/bin/activate
pip config set global.index-url $MIRRORS/pypi/simple
pip install -U pip # update before install modules
pip install -r requirements.txt
pip cache purge

# pip install <package>
# save with 'pip freeze > requirements.txt' in venv
deactivate

which go &> /dev/null || info "== Please install host toolchain 'golang' for Go support"
which rustc &> /dev/null || info "== Please install host toolchain 'cargo|rustc' for Rust support"

# install prebuilts
case "$OSTYPE" in
    darwin*)    ARCH="$(uname -m)-apple-darwin" ;;
    *)          ARCH="$(uname -m)-$OSTYPE"      ;;
esac
URL="https://pub.mtdcy.top/cmdlets/latest/$ARCH/app/nvim/nvim.tar.gz"

if curl --fail -sI -o /dev/null "$URL"; then
    mkdir -pv "prebuilts/$ARCH"
    curl -sL "$URL" | tar -x -C "prebuilts/$ARCH"
    # => gunzip applied automatically
else
    info "== Please install nvim manually"
fi

# install symlinks
INSTBIN=/usr/local/bin
info "== install nvim to $INSTBIN"
sudo ln -svf "$PWD/run" "$INSTBIN/nvim"
sudo ln -svf "$PWD/scripts/ncopyd.sh" "$INSTBIN"
sudo ln -svf "$PWD/scripts/ncopyc.sh" "$INSTBIN"
# nvim final prepare
$INSTBIN/nvim -c 'packloadall | silent! helptags ALL | UpdateRemotePlugins' +quit
