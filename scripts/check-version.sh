#!/bin/sh
# check-version.sh <tag>
# Release tags are v<upstream>.<pkgrel>, like AUR's pkgver-pkgrel but with a dot so that the
# Pak Store can compare them: <upstream> is the release tag the yabadabadoo submodule is checked
# out at, padded to three numbers (v0.3 -> 0.3.0), and <pkgrel> counts the pak's releases of that
# upstream version from 1 (v0.3.0.1, v0.3.0.2, then v0.4.0.1). The tag must also be the version
# in pak.json, since the Pak Store downloads releases/download/<version>/<release_filename>.
set -e
[ $# -eq 1 ] || { echo "usage: $0 <tag>" >&2; exit 2; }
tag=$1
cd "$(dirname "$0")/.."

fail() {
	echo "::error::$*" >&2
	exit 1
}

version=$(jq -r .version pak.json)
[ "$version" = "$tag" ] || fail "pak.json's version is $version but the tag is $tag"

upstream_tag=$(git -C yabadabadoo describe --tags --exact-match HEAD 2>/dev/null) ||
	fail "the yabadabadoo submodule is not checked out at a release tag"
upstream=$(echo "${upstream_tag#v}" | awk -F. '
	NF > 3 { exit 1 }
	{ for (i = 1; i <= NF; i++) if ($i !~ /^[0-9]+$/) exit 1 }
	{ printf "%s.%s.%s", $1, (NF > 1 ? $2 : 0), (NF > 2 ? $3 : 0) }') ||
	fail "the yabadabadoo submodule is at $upstream_tag, which is not a release version"

case $tag in
v"$upstream".[1-9]*) pkgrel=${tag#v"$upstream".} ;;
*) fail "the tag $tag does not start with v$upstream. (yabadabadoo $upstream_tag)" ;;
esac
case $pkgrel in
*[!0-9]*) fail "the tag $tag does not end with a release number after v$upstream." ;;
esac

echo "$tag: yabadabadoo $upstream_tag, pak release $pkgrel"
