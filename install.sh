#!/bin/bash

echo "$0 $@"

set -eo pipefail

info() { echo -e "\\033[31m$*\\033[39m"; }

locally=0
if curl --fail -sIL https://git.mtdcy.top -o /dev/null; then
    locally=1
fi

# install prebuilts
case "$OSTYPE" in
    darwin*)    ARCH="$(uname -m)-apple-darwin" ;;
    *)          ARCH="$(uname -m)-$OSTYPE"      ;;
esac

case "$1" in
    --prepare)
        cd scripts
        # no public repo of cmdlets => install locally
        curl -sL -o cmdlets.sh https://git.mtdcy.top/mtdcy/cmdlets/raw/branch/main/cmdlets.sh
        chmod a+x cmdlets.sh

        archs=(
            x86_64-linux-gnu
            x86_64-linux-musl
            x86_64-apple-darwin
        )

        rm -rf prebuilts
        for x in "${archs[@]}"; do
            export CMDLETS_ARCH="$x"
            export CMDLETS_STRIP=0
            ./cmdlets.sh install nvim
            ./cmdlets.sh install ctags
            ./cmdlets.sh install rg     # ripgrep
        done
        exit
        ;;
esac

if [ -z "$1" ] || [ "$1" = "--update" ]; then
    if [ -f "$(dirname "$0")/init.vim" ]; then
        cd "$(dirname "$0")"
        info "== update pretty.nvim @ $PWD"
        git pull --rebase --force
    elif [ -d "$HOME/.nvim" ]; then
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

    exec ./install.sh --no-update
fi

if [ "$locally" -eq 1 ]; then
    MIRRORS=https://mirrors.mtdcy.top
fi

# Host prepare
requirements=(curl python3)
for x in "${requirements[@]}"; do
    which "$x" || { info "== Please install host tool $x first"; exit 1; }
done

# install python modules with venv
#  python3.13 has problems to install modules.
if python3 --version | grep -Fw 3.13; then
    info "== python3.13 has troubles to install modules"
    python3.12 -m venv --copies --clear py3env
else
    python3 -m venv --copies --clear py3env
fi

source py3env/bin/activate
if [ -z "$MIRRORS" ]; then
    pip install -U pip # update before install modules
    pip install -r requirements.txt
else
    pip install -i "$MIRRORS/pypi/simple" -U pip # update before install modules
    pip install -i "$MIRRORS/pypi/simple" -r requirements.txt
fi
pip cache purge

# pip install <package>
# save with 'pip freeze > requirements.txt' in venv
deactivate

# install node modules locally
if which npm; then
    [ -n "$MIRRORS" ] && npm config set registry "$MIRRORS/npmjs" || true
    npm install
    # install package with 'npm install <name>' && save with 'npm init'
    npm cache clean --force
else
    info "== Please install npm|nodejs for full features"
fi

# install go tools
if which go; then
    go install golang.org/x/tools/gopls@latest
    go install golang.org/x/tools/cmd/goimports@latest
    go install github.com/mrtazz/checkmake/cmd/checkmake@latest
    go install github.com/jesseduffield/lazygit@latest
else
    info "== Please install host toolchain 'golang' for Go support"
fi

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

"$INSTBIN/nvim" -c 'call fruzzy#install()' +quit || true

"$INSTBIN/nvim" -c 'exe "normal iHello NeoVim!\<Esc>" | wq' /tmp/$$-nvim-install.txt

trap "rm -f /tmp/$$-nvim-install.txt" EXIT
[ "$(cat /tmp/$$-nvim-install.txt)" = "Hello NeoVim!" ] || {
    info "== Something went wrong with pretty.nvim"
    exit 1
}

check_host() {
    if which "$1"; then
        return 0
    else
        info "== Please install $1 for $2 support"
        return 1
    fi
}

check_host ccls                 "better C/C++"  || true
check_host rustc                Rust            || true
check_host checkmake            Makefile        || true
check_host lazygit              LazyGit         || true

# Lua
check_host lua-language-server  Lua             || true
check_host luarocks             Luacheck && {
    luarocks install --local luacheck
    luarocks install --local lanes
} || true
check_host stylua               "Lua formatter" || true

check_host shfmt                "shell script"  || true
