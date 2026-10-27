#!/bin/sh
# Builds yabadabadoo_libretro.so for one NextUI platform. Runs inside that
# platform's toolchain container (ghcr.io/loveretro/<platform>-toolchain),
# which sets CROSS_COMPILE. Usage: build-core.sh <platform> <output dir>
set -eu

PLATFORM=$1
OUT=$2
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC=$ROOT/build/src-$PLATFORM

rm -rf "$SRC"
mkdir -p "$SRC" "$OUT"
# Patch a copy, so the submodule checkout stays clean
git -c safe.directory='*' -C "$ROOT/upstream" archive --format=tar HEAD | tar -x -C "$SRC"
for patch in "$ROOT"/patches/*.patch; do
	patch -d "$SRC" -p1 --forward < "$patch"
done

# The Makefile embeds the commit hash; the copy is not a git checkout
GIT_REV=$(git -c safe.directory='*' -C "$ROOT/upstream" rev-parse --short HEAD)
make -C "$SRC/yabause/src/libretro" platform="$PLATFORM" \
	GIT_VERSION="\" $GIT_REV\"" -j"$(nproc)"

cp "$SRC/yabause/src/libretro/yabadabadoo_libretro.so" "$OUT/"
"${CROSS_COMPILE}strip" --strip-unneeded "$OUT/yabadabadoo_libretro.so"
