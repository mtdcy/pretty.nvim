#!/bin/sh -eu

_in='/tmp/langserv2vim'
_out='/tmp/vim2langserv'

#_bashls="$(which bash-language-server)"
_bashls="$(dirname "$0")/../node_modules/.bin/bash-language-server"

export BASH_IDE_LOG_LEVEL=info

tee "$_out" | "$_bashls" "$@" | tee "$_in"

unset _in _out _langserv
