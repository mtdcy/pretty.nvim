#!/usr/bin/env bash

echo "$0 $@"

set -eo pipefail

: "${INSTBINDIR:=/usr/local/bin}"

# set in nvim entry when do `nvim --update'
unset XDG_CONFIG_HOME

info() { echo -e "\\033[31m$*\\033[39m"; }

case "$OSTYPE" in
    darwin*) ARCH="$(uname -m)-apple-darwin" ;;
    *)       ARCH="$(uname -m)-$OSTYPE"      ;;
esac

REPO=(
    https://git.mtdcy.top/mtdcy/pretty.nvim.git
    https://github.com/mtdcy/pretty.nvim.git
)

VERSION=0.11.7

PREBUILTS=(
    https://git.mtdcy.top/mtdcy/nvim-build/releases/download/$VERSION/$ARCH.tar.gz
    https://github.com/mtdcy/nvim-build/releases/download/$VERSION/$ARCH.tar.gz
)

cmdlets=(
    http://git.mtdcy.top/mtdcy/cmdlets/raw/branch/main/cmdlets.sh
    https://raw.githubusercontent.com/mtdcy/cmdlets/main/cmdlets.sh
)

# mandatory tools
tools=(lazygit rg socat)

optionals=(ctags checkmake shfmt delta shellcheck fd)

MIRRORS=https://mirrors.mtdcy.top

CURL_OPTS=(-sL --fail --connect-timeout 1)

__curl() { curl "${CURL_OPTS[@]}" "$@"; }

__curl -I "$MIRRORS" -o /dev/null || unset MIRRORS

# _curl file urls...
_curl() {
    for url in "${@:2}"; do
        info "🚀 curl < $url"
        __curl -I "$url" -o /dev/null || continue
        __curl    "$url" -o "$1" && return 0 || true
    done
    return 1
}

if [ -z "$1" ] || [ "$1" = "--update" ]; then
    if [ -f "$(dirname "$0")/init.vim" ]; then
        pushd "$(dirname "$0")"
        info "🚀 update pretty.nvim @ $PWD"
        git pull --rebase --force
    elif [ -d "$HOME/.nvim" ]; then
        info "🚀 update pretty.nvim @ ~/.nvim"
        pushd "$HOME/.nvim"
        git pull --rebase --force
    else
        for repo in "${REPO[@]}"; do
            # test connection
            __curl -I "$repo" -o /dev/null || continue

            info "🚀 clone pretty.nvim < $repo"
            git clone --depth=1 "$repo" "$HOME/.nvim" && break || true
        done
        pushd "$HOME/.nvim"
    fi

    exec ./install.sh --update-core
fi

if [ "$1" = "--update-core" ] || [ "$1" = "--update-core-exit" ]; then
    rm -rf prebuilts
    mkdir -p prebuilts

    # shellcheck disable=SC2064
    temp="$(mktemp -d)" && trap "rm -rf $temp" EXIT

    if _curl "$temp/$ARCH.tar.gz" "${PREBUILTS[@]}" && tar -C prebuilts -xzf "$temp/$ARCH.tar.gz"; then
        info "✅ Download $(./prebuilts/bin/nvim --version | grep "^NVIM")"
    else
        info "❌ Download prebuilts failed"
        exit 1
    fi

    if _curl cmdlets.sh "${cmdlets[@]}"; then
        info "✅ Download cmdlets.sh"
    else
        info "❌ Download cmdlets.sh failed"
        exit 2
    fi
    chmod a+x cmdlets.sh

    if ./cmdlets.sh fetch "${tools[@]}"; then
        info "✅ Download ${tools[*]}"
    else
        info "❌ Download ${tools[*]} failed"
        exit 3
    fi

    ./cmdlets.sh fetch "${optionals[@]}" || true

    # remove unneeded files
    rm -rf prebuilts/caveats || true
    find prebuilts -name "*.tar.*" -exec rm -fv {} \; || true
    find prebuilts -type d -empty -exec rm -rfv {} \; || true

    [ "$1" = "--update-core" ] || exit 0

    rm -rf "$temp" # exec ignores trap
    exec "$0" --no-update
fi

# Host prepare
requirements=(curl python3)
for x in "${requirements[@]}"; do
    if ! which "$x"; then
        info "❌ Please install $x first"
        exit 1
    fi
done

info "🚀 Install fonts"
case "$OSTYPE" in
    darwin*)
        mkdir -p ~/Library/Fonts
        cp -f fonts/* ~/Library/Fonts
        ;;
    *)
        mkdir -p ~/.fonts
        cp -f fonts/* ~/.fonts/
        fc-cache -fv || true # ignore errors
        ;;
esac

info "🚀 Install python wheels"

# true: fix 'Text file busy' if nvim is openned
#  no --upgrade-deps with python 3.8-
python3 -m venv --copies py3env || true

# update wheels with:
#  pip install pur
#  pur -r requirements.txt
source py3env/bin/activate
if [ -z "$MIRRORS" ]; then
    pip install -U pip # update before install modules
    pip install -r requirements.txt --quiet
else
    pip install -i "$MIRRORS/pypi/simple" -U pip # update before install modules
    pip install -i "$MIRRORS/pypi/simple" -r requirements.txt --quiet
fi
pip cache purge || true

# pip install <package>
# save with 'pip freeze > requirements.txt' in venv
deactivate

# Install node modules locally
#  update package.json:
#    npm install -g npm-check-updates
#    ncu -u
if which npm; then
    info "🚀 Install node modules with npm"
    # new version npm does not support url subdir
    [ -n "$MIRRORS" ] && npm config set registry "$MIRRORS/npmjs/" || true
    npm install --quiet
    # install package with 'npm install <name>' && save with 'npm init'
    npm cache clean --force
else
    info "⚠️  Please install npm|nodejs for full features"
fi

# nvim final prepare
./run --headless -c 'packloadall | silent! helptags ALL | UpdateRemotePlugins' +quit

# test
./run -c 'exe "normal iHello NeoVim!\<Esc>" | wq' /tmp/$$-nvim-install.txt
trap "rm -f /tmp/$$-nvim-install.txt" EXIT
[ "$(cat /tmp/$$-nvim-install.txt)" = "Hello NeoVim!" ] || {
    info "❌ Something went wrong with pretty.nvim"
    exit 1
}

# Install git config
touch "$HOME/.gitconfig"
if ! grep -q "pretty.nvim gitconfig" "$HOME/.gitconfig"; then
    info "🚀 Install pretty.nvim gitconfig"
    cat << EOF >> "$HOME/.gitconfig"

# Include pretty.nvim gitconfig
[include]
    path = $(pwd -P)/gitconfig

EOF
fi

# 我们不再安装 lazygit config，这是 nvim 专用的
# Install lazygit config (always override existings)
# _lazygit="$(./prebuilts/bin/lazygit -cd)"
# mkdir -p "$_lazygit"
# info "🚀 Install lazygit.yml => $_lazygit/config.yml"

# test -L "$_lazygit/config.yml" || mv "$_lazygit/config.yml"{,.old} || true
# ln -sfv "$(pwd -P)/lazygit.yml" "$_lazygit/config.yml"

info "🚀 Install pretty.nvim to $INSTBINDIR"

sudo ln -svf "$(pwd -P)/run"                    "$INSTBINDIR/nvim"
sudo ln -svf "$(pwd -P)/scripts/nopen.sh"       "$INSTBINDIR"
sudo ln -svf "$(pwd -P)/scripts/nsshc.sh"       "$INSTBINDIR"
sudo ln -svf "$(pwd -P)/scripts/nclients.sh"    "$INSTBINDIR"
sudo ln -svf "$(pwd -P)/scripts/nvim-helpers.sh" "$INSTBINDIR"

# Install launch daemons
if which launchctl; then
    PLIST="$HOME/Library/LaunchAgents/com.mtdcy.nvim-helpers.plist"
    info "🚀 Install $PLIST"

    sed -e "s%__PATH__%$PATH%" \
        -e "s%__NVIM_HOME__%$(pwd -P)%" \
        scripts/nvim-helpers.plist > "$PLIST"

    launchctl unload "$PLIST" 2> /dev/null || true
    launchctl load -w "$PLIST"
fi

check_host() {
    if which "$1"; then
        return 0
    else
        info "⚠️  Please install $1 for $2 support"
        return 1
    fi
}

check_host clangd               "better C/C++"  || true
check_host go                   Go              || true
check_host rustc                Rust            || true
