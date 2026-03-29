#!/bin/sh -eu

_in='/tmp/langserv2vim'
_out='/tmp/vim2langserv'

#_luals="$(which lua-language-server)"
_luals="/home/mtdcy/lua-language-server/bin/lua-language-server"
_config="$HOME/.nvim/lintrc/luarc.json"

tee "$_out" | "$_luals" --loglevel='error' "$@" | tee "$_in"
#"$_luals" --configpath="$(dirname "$0")/luals.lua" --loglevel='error' "$@"

unset _in _out _langserv

