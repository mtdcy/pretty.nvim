#!/bin/bash -e

# determine arch
case "$OSTYPE" in
    darwin*)
        ARCH="$(uname -m)-apple-darwin"
        ;;
    linux-gnu)
        if find /lib*/ld-linux-* &>/dev/null; then
            ARCH="$(uname -m)-linux-gnu"
        elif find /lib*/ld-musl-* &>/dev/null; then
            ARCH="$(uname -m)-linux-musl"
        else
            echo "Unknown OSTYPE $OSTYPE"
        fi
        ;;
    *)
        ARCH="$(uname -m)-$OSTYPE"
        ;;
esac

exec "$(dirname "$0")/prebuilts/$ARCH/bin/ctags" "$@"
