#!/usr/bin/env bash

if test -z "$NVIM_REMOTE_SOCKET"; then
    echo "❌ NVIM_REMOTE_SOCKET not set"
    exit 1
fi

echo "$@"

# 💡 如果有 popup 或 term 存在，--remote <filename> 会被截获，从而导致异常。
# ⚠️ disown: open inside nvim will cause deadlock
"${NVIM_EXECUTABLE:-nvim}" \
    -u NONE --headless \
    --server "$NVIM_REMOTE_SOCKET" \
    --remote-silent "$(realpath "$@" | xargs)" \
    & disown

exit 0
