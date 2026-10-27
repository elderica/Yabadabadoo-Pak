#!/bin/sh
# update-upstream.sh [tag]
# Checks out upstream's newest release tag (or the given one) in the yabadabadoo submodule and
# makes pak.json's version its first pak release, v<upstream>.1, with a changelog entry.
# Prints the new version, or nothing when the submodule is already at that release or a newer one.
# Betas (v0.4-beta.1) are not releases and are never picked.
set -e
cd "$(dirname "$0")/.."

git -C yabadabadoo fetch --quiet --tags origin
if [ $# -ge 1 ]; then
	tag=$1
else
	tag=$(git -C yabadabadoo tag --list 'v*' | grep -E '^v[0-9]+(\.[0-9]+){0,2}$' | sort -V | tail -n 1)
	[ -n "$tag" ] || { echo "no release tag upstream" >&2; exit 1; }
fi
upstream=$(scripts/upstream-version.sh "$tag") || { echo "$tag is not a release version" >&2; exit 1; }

# The release the submodule is at, or the last one before it when Dependabot moved it past a tag
current=$(git -C yabadabadoo describe --tags --abbrev=0 --match 'v*' HEAD 2>/dev/null || true)
current_upstream=$(scripts/upstream-version.sh "$current" 2>/dev/null || echo 0.0.0)
if [ "$current_upstream" = "$upstream" ] ||
	[ "$(printf '%s\n%s\n' "$current_upstream" "$upstream" | sort -V | tail -n 1)" != "$upstream" ]; then
	echo "yabadabadoo is at $current, nothing newer than $tag" >&2
	exit 0
fi

version=v$upstream.1
git -C yabadabadoo checkout --quiet "$tag"
jq --indent 2 --arg v "$version" --arg msg "Update Yabadabadoo to $tag." \
	'.version = $v | .changelog[$v] = $msg' pak.json > pak.json.tmp
mv pak.json.tmp pak.json
scripts/check-version.sh "$version" >&2
echo "$version"
