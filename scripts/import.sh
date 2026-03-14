#!/bin/bash -e
#
# Usage: import.sh https://github.com/jlanzarotta/bufexplorer.git[@master|@v1.0.0]

IFS='@' read -r url ref <<< "$1"

repo="$(basename "$url")"
repo="${repo%%.*}"
# default branch: master
ref="${ref:-master}"

if ! git ls-remote --exit-code "$repo" &>/dev/null; then
    git remote add "$repo" "$url"
else
    git remote set-url "$repo" "$url"
fi

git fetch "$repo"

# Auto-detect if ref is a tag or branch
if git rev-parse "refs/tags/$ref" &>/dev/null; then
    echo "📌 Importing from tag: $repo@$ref"
    git merge "refs/tags/$ref" --allow-unrelated-histories --no-commit --squash --ff -X theirs
else
    echo "📌 Importing from branch: $repo@$ref"
    git merge "$repo/$ref" --allow-unrelated-histories --no-commit --squash --ff -X theirs
fi

git restore --staged .
git checkout HEAD -- README.md .gitignore .github   # checkout ours
git clean -f -d .github                             # clean unneeded

mv LICENSE "LICENSE.$repo" -f || true               # rename LICENSE
rm test tests -rf || true                           # ...

# common vim directories
git add after autoload colors doc ftdetect ftplugin indent lua plugin rplugin syntax "LICENSE.$repo" || true

echo -e "\n🚀 It's time to remove unneeded files and commit ..."
