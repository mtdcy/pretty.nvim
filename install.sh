#!/bin/bash

echo "$0 $@"

set -eo pipefail

info() { echo -e "\\033[31m$*\\033[39m"; }

# install prebuilts
case "$OSTYPE" in
    darwin*)    ARCH="$(uname -m)-apple-darwin" ;;
    *)          ARCH="$(uname -m)-$OSTYPE"      ;;
esac

# no public repo of cmdlets => install locally
if [ "$1" = "cmdlets" ]; then
    cmdlets="https://git.mtdcy.top/mtdcy/cmdlets/raw/branch/main/cmdlets.sh"
    archs=(
        x86_64-linux-gnu
        x86_64-linux-musl
        x86_64-apple-darwin
    )

    rm -rf prebuilts
    for x in "${archs[@]}"; do
        CMDLETS_ARCH="$x" bash -c "$(curl -fsSL "$cmdlets")" fetch nvim
    done
    exit
fi

locally=0
if curl --fail -sIL https://git.mtdcy.top -o /dev/null; then
    locally=1
fi

if [ "$0" = "install" ] || [ "$0" = "bash" ]; then
    if [ -d "$HOME/.nvim" ]; then
        info "== update pretty.nvim @ ~/.nvim"
        cd "$HOME/.nvim"
        git pull --rebase --force
    else
        info "== clone pretty.nvim => ~/.nvim"
        if [ "$locally" -eq 1 ]; then
            git clone --depth=1 https://git.mtdcy.top/mtdcy/pretty.nvim.git "$HOME/.nvim"
        else
            git clone --depth=1 https://github.com/mtdcy/pretty.nvim.git "$HOME/.nvim"
        fi
        cd "$HOME/.nvim"
    fi
fi

if [ "$locally" -eq 1 ]; then
    MIRRORS=https://mirrors.mtdcy.top
fi

# Host prepare
requirements=(curl npm python3)
for x in "${requirements[@]}"; do
    which "$x" || { info "== Please install host tool $x first"; exit 1; }
done

# install node modules locally
npm config set registry "$MIRRORS/npmjs"
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
pip install -i "$MIRRORS/pypi/simple" -U pip # update before install modules
pip install -i "$MIRRORS/pypi/simple" -r requirements.txt
pip cache purge

# pip install <package>
# save with 'pip freeze > requirements.txt' in venv
deactivate

which go &> /dev/null || info "== Please install host toolchain 'golang' for Go support"
which rustc &> /dev/null || info "== Please install host toolchain 'cargo|rustc' for Rust support"

# install symlinks
INSTBIN=/usr/local/bin
if [[ "$PATH" =~ $HOME/.bin ]]; then
    INSTBIN="$HOME/.bin"
fi
info "== install nvim to $INSTBIN"
if [ -w "$INSTBIN" ]; then
    ln -svf "$PWD/run" "$INSTBIN/nvim"
    ln -svf "$PWD/scripts/ncopyd.sh" "$INSTBIN"
    ln -svf "$PWD/scripts/ncopyc.sh" "$INSTBIN"
else
    sudo ln -svf "$PWD/run" "$INSTBIN/nvim"
    sudo ln -svf "$PWD/scripts/ncopyd.sh" "$INSTBIN"
    sudo ln -svf "$PWD/scripts/ncopyc.sh" "$INSTBIN"
fi

# nvim final prepare
"$INSTBIN/nvim" -c 'packloadall | silent! helptags ALL | UpdateRemotePlugins' +quit

"$INSTBIN/nvim" -c 'exe "normal iHello NeoVim!\<Esc>" | wq' /tmp/$$-nvim-install.txt

[ "$(cat /tmp/$$-nvim-install.txt)" = "Hello NeoVim!" ] || {
    info "== Something went wrong with pritty.nvim"
    exit 1
}
