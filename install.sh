#!/bin/bash

set -eo pipefail

cd $(dirname "$0")

info() { echo -e "\\033[31m$*\\033[39m"; }

# Host prepare
requirements=(curl npm python3)
for x in "${requirements[@]}"; do
    which "$x" || { info "== Please install host tool $x first"; exit 1; }
done

# install node modules locally
[ -n "$MIRRORS" ] && npm  config set registry $MIRRORS/npmjs
npm install
# install package with 'npm install <name>' && save with 'npm init'
npm cache clean --force

# install python modules with venv
# always remove py3env as interpretor is hardcoded in venv
rm -rf py3env || true
#$pip install neovim cmakelint cmake-format yamllint yamlfix autopep8
python3 -m venv py3env
source py3env/bin/activate
if [ -n "$MIRRORS" ]; then
    python3 -m pip config set global.index-url $MIRRORS/pypi/simple
fi

python3 -m pip install -r requirements.txt
python3 -m pip cache purge

# python3 -m pip install <package>
# save with 'python3 -m pip freeze > requirements.txt' in venv
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
INSTBIN=/usr/local/bin/nvim
if [ -f "$INSTBIN" ]; then
    info "== Please link nvim manually: ln -svf $PWD/run /path/to/bin/nvim"
else
    unlink "$INSTBIN" &> /dev/null || true
    sudo ln -svf "$PWD/run" "$INSTBIN"
    # nvim final prepare
    $INSTBIN -c 'packloadall | silent! helptags ALL | UpdateRemotePlugins' +quit
fi
