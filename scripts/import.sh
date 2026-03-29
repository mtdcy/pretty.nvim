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

# override existing tags
git fetch "$repo" --prune --prune-tags --tags --force

# Auto-detect if ref is a tag or branch
if git rev-parse "refs/tags/$ref" &>/dev/null; then
    echo "📌 Importing from tag: $repo@$ref"
    git merge "refs/tags/$ref" --allow-unrelated-histories --no-commit --squash --ff -X theirs
else
    echo "📌 Importing from branch: $repo@$ref"
    git merge "$repo/$ref" --allow-unrelated-histories --no-commit --squash --ff -X theirs
fi

git restore --staged .

# checkout ours
for x in README.md .gitignore .github; do
    git checkout HEAD -- "$x" || true               # checkout ours
    test -f "$x" || git clean -f -d "$x" || true    # clean unneeded files
done

mv LICENSE      "LICENSE.$repo" -f ||               # rename LICENSE
mv LICENSE.md   "LICENSE.$repo" -f || true          # rename LICENSE
rm test tests -rf || true                           # ...

# common vim directories
git add --ignore-errors after autoload doc/$repo.txt ftdetect ftplugin indent lua plugin rplugin syntax "LICENSE.$repo" || true

echo -e "\n🚀 It's time to remove unneeded files and commit ..."
