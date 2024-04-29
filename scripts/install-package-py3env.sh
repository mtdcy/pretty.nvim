#!/bin/bash
#
# Usage: $0 packages

set -eo pipefail

WORKDIR=py3env

[ -f $WORKDIR/pyvenv.cfg ] || {
    python3 -m venv $WORKDIR
}

source $WORKDIR/bin/activate

trap deactivate EXIT

if [ $# -gt 0 ]; then
    python3 -m pip install "$@"
else
    python3 -m pip install -r requirements.txt
fi

python3 -m pip freeze > requirements.txt
