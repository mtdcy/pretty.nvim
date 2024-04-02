#!/bin/bash
#
# usage:
#  import.sh https://github.com/jlanzarotta/bufexplorer.git

set -x

repo="$1"
name="$(basename "${repo%.git}")"

main="${2:-master}"

work="$(git rev-parse --abbrev-ref HEAD)"

git remote add "$name" "$repo" || true # exists?

git fetch "$name" --no-tags &&
git checkout -b "$name" --track "$name/$main" &&
git pull "$name" "$main" &&
git checkout "$work" &&
git merge "$name" --allow-unrelated-histories --no-commit --squash # conflicts

# keep our files
git checkout HEAD -- README.md .gitignore

# remove unneeded
git rm -rf .github test tests CONTRIBUTING.md --ignore-unmatch

[ -f LICENSE ] && mv LICENSE "LICENSE.$name"
[ -f LICENSE.txt ] && mv LICENSE.txt "LICENSE.$name"

# do manually ...
