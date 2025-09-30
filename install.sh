#!/bin/bash

echo "$0 $@"

set -eo pipefail

info() { echo -e "\\033[31m$*\\033[39m"; }

case "$OSTYPE" in
    darwin*) ARCH="$(uname -m)-apple-darwin" ;;
    *)       ARCH="$(uname -m)-$OSTYPE"      ;;
esac

REPO=(
    https://git.mtdcy.top/mtdcy/pretty.nvim.git
    https://github.com/mtdcy/pretty.nvim.git
)

VERSION=0.10.4

PREBUILTS=(
    https://git.mtdcy.top/mtdcy/nvim-build/releases/download/$VERSION/$ARCH.tar.gz
    https://github.com/mtdcy/nvim-build/releases/download/$VERSION/$ARCH.tar.gz
)

cmdlets=(
    http://git.mtdcy.top/mtdcy/cmdlets/raw/branch/main/cmdlets.sh
    https://raw.githubusercontent.com/mtdcy/cmdlets/main/cmdlets.sh
)

tools=( lazygit ctags ripgrep checkmake )

MIRRORS=https://mirrors.mtdcy.top

CURL_OPTS=( -sL --fail --connect-timeout 1 )

__curl() { curl "${CURL_OPTS[@]}" "$@"; }

__curl -I "$MIRRORS" -o /dev/null || unset MIRRORS

# _curl file urls...
_curl() {
    for url in "${@:2}"; do
        info "== curl < $url"
        __curl -I "$url" -o /dev/null || continue
        __curl    "$url" -o "$1" && return 0 || true
    done
    return 1
}

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
        for repo in "${REPO[@]}"; do
            # test connection
            __curl -I "$repo" -o /dev/null || continue

            info "== clone pretty.nvim < $repo"
            git clone --depth=1 "$repo" "$HOME/.nvim" && break || true
        done
        cd "$HOME/.nvim"
    fi

    exec ./install.sh --update-core
fi

if [ "$1" = "--update-core" ] || [ "$1" = "--update-core-exit" ]; then
    # download prebuilts
    mkdir -p prebuilts

    # shellcheck disable=SC2064
    temp="$(mktemp -d)" && trap "rm -rf $temp" EXIT

    _curl "$temp/$ARCH.tar.gz" "${PREBUILTS[@]}" && tar -C prebuilts -xzf "$temp/$ARCH.tar.gz" || {
        info "== Download prebuilts failed"
        exit 1
    }

    _curl cmdlets.sh "${cmdlets[@]}" || {
        info "== Download cmdlets failed"
        exit 2
    }
    chmod a+x cmdlets.sh
    ./cmdlets.sh fetch "${tools[@]}" || true
    find prebuilts -name "*.tar.*" -exec rm -fv {} \; || true

    [ "$1" = "--update-core" ] || exit 0

    exec "$0" --no-update
fi

# Host prepare
requirements=(curl python3)
for x in "${requirements[@]}"; do
    which "$x" || { info "== Please install host tool $x first"; exit 1; }
done

# install python modules with venv => python3.10 preferred
#  python3.13 has problems to install modules.
py3="$(which python3.10)" || py3="$(which python3)"

# remove py3env => may cause problems
rm -rf py3env || true

# 'Text file busy' if nvim is openned
$py3 -m venv --copies --upgrade-deps py3env || true

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
    # new version npm does not support url subdir
    [ -n "$MIRRORS" ] && npm config set registry "${MIRRORS/mirrors/npmjs}" || true
    npm install
    # install package with 'npm install <name>' && save with 'npm init'
    npm cache clean --force
else
    info "== Please install npm|nodejs for full features"
fi

# install symlinks
INSTBIN=/usr/local/bin
info "== install nvim to $INSTBIN"

sudo ln -svf "$(pwd -P)/run"                "$INSTBIN/nvim"
sudo ln -svf "$(pwd -P)/scripts/ncopyd.sh"  "$INSTBIN"
sudo ln -svf "$(pwd -P)/scripts/ncopyc.sh"  "$INSTBIN"

# nvim final prepare
"$INSTBIN/nvim" -c 'packloadall | silent! helptags ALL | UpdateRemotePlugins' +quit

"$INSTBIN/nvim" -c 'call fruzzy#install()' +quit || true

"$INSTBIN/nvim" -c 'exe "normal iHello NeoVim!\<Esc>" | wq' /tmp/$$-nvim-install.txt

if which launchctl; then
    PLIST="$HOME/Library/LaunchAgents/com.mtdcy.ncopyd.plist"
    cp scripts/ncopyd.plist "$PLIST"
    launchctl unload "$PLIST" 2>/dev/null || true
    launchctl load -w "$PLIST"
fi

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
check_host go                   Go              || true
check_host rustc                Rust            || true
check_host checkmake            Makefile        || true

# Lua
check_host lua-language-server  Lua             || true
check_host luacheck             Luacheck        || true
check_host stylua               "Lua formatter" || true
