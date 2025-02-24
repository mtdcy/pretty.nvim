#!/bin/bash -e
#
# Usage: import.sh https://github.com/jlanzarotta/bufexplorer.git[@master]

IFS='@' read -r url branch <<< "$1"

repo="$(basename "$url")"
repo="${repo%%.*}"
# default branch: master
branch="${branch:-master}"

if ! git ls-remote --exit-code "$repo" &>/dev/null; then
    git remote add "$repo" "$url"
else
    git remote set-url "$repo" "$url"
fi
git fetch "$repo"
git merge "$repo/$branch" --allow-unrelated-histories --no-commit --squash -X theirs
git restore --staged .
git checkout HEAD -- README.md .gitignore .github   # checkout ours
git clean -f -d .github                             # clean unneeded

mv LICENSE "LICENSE.$repo" -f || true               # rename LICENSE
rm test tests -rf || true                           # ...

# common vim directories
git add after autoload colors doc ftdetect ftplugin indent plugin rplugin syntax "LICENSE.$repo" || true

echo -e "\n>>> It's time to remove unneeded files and commit ..."
