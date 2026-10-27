#!/bin/sh
# Packs the cores built by build-core.sh (build/cores/<platform>/) into the
# release archives in dist/:
#   SATURN.pak.zip               the pak folder's contents with the cores of
#                                all platforms (Pak Store format)
#   Yabadabadoo-Pak-<version>.zip  ready to extract to the SD card root
# Usage: package.sh <version>
set -eu

VERSION=$1
TAG=SATURN
ROM_DIR="Sega Saturn ($TAG)"
PLATFORMS="h700 tg5040 tg5050"
ROOT=$(cd "$(dirname "$0")/.." && pwd)
STAGE=$ROOT/build/stage
DIST=$ROOT/dist

rm -rf "$STAGE" "$DIST"
mkdir -p "$STAGE" "$DIST"

# Files every copy of the pak carries
pak_files() {
	mkdir -p "$1"
	cp "$ROOT/pak/launch.sh" "$ROOT/pak/default.cfg" "$1/"
	chmod +x "$1/launch.sh"
	cp "$ROOT/upstream/yabause/COPYING" "$1/COPYING.txt"
	cp "$ROOT/upstream/packaging/THIRD-PARTY-NOTICES.txt" "$1/"
	printf '%s\n' "$VERSION" > "$1/version.txt"
}

# Pak Store: one pak folder for every platform
PAK=$STAGE/pak
pak_files "$PAK"
for p in $PLATFORMS; do
	mkdir -p "$PAK/cores/$p"
	cp "$ROOT/build/cores/$p/yabadabadoo_libretro.so" "$PAK/cores/$p/"
done
(cd "$PAK" && zip -qr -X "$DIST/$TAG.pak.zip" .)

# SD card: each platform folder gets only its own core
SD=$STAGE/sdcard
for p in $PLATFORMS; do
	pak_files "$SD/Emus/$p/$TAG.pak"
	cp "$ROOT/build/cores/$p/yabadabadoo_libretro.so" "$SD/Emus/$p/$TAG.pak/"
done
mkdir -p "$SD/Bios/$TAG" "$SD/Roms/$ROM_DIR"
(cd "$SD" && zip -qr -X "$DIST/Yabadabadoo-Pak-$VERSION.zip" .)

ls -l "$DIST"
