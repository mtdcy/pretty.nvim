#!/bin/bash
# setup a remote socket for coping text back

set -eo pipefail

# 确保 UTF-8 编码
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

: "${XDG_RUNTIME_DIR:=$(getconf DARWIN_USER_TEMP_DIR)}"
: "${NVIM_HELPER_PORT:=18643}"
: "${NVIM_HELPER_PIDFILE:=$XDG_RUNTIME_DIR/nvim.helpers.pid}"

: "${SSH_SOCKET:=$NVIM_HELPER_PORT}"

if test -f "$NVIM_HELPER_PIDFILE"; then
    if ! ps -p $(cat "$NVIM_HELPER_PIDFILE") >/dev/null; then
        echo "⚠️ start nvim.helpers"
        nvim-helpers.sh & disown
    fi
fi

ssh -q -t -R "$SSH_SOCKET:localhost:$NVIM_HELPER_PORT" "$@" \
    "export SSH_SOCKET=$SSH_SOCKET; exec \$SHELL -li"
