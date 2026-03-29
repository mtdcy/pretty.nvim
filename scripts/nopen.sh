#!/bin/bash

if test -z "$NVIM_REMOTE_SOCK"; then
    echo "❌ NVIM_REMOTE_SOCK not set"
    exit 1
fi

# remote is synchronized, call nopen.sh in nvim will block it
nvim --server "$NVIM_REMOTE_SOCK" --remote "$@"
