#!/bin/sh

EMU_EXE=yabadabadoo
PAK_DIR=$(dirname "$0")

# The pak carries one core per platform: cores/<platform>/ (Pak Store
# install) or, in the SD card zip, just the one for the platform it sits in.
CORES_PATH="$PAK_DIR/cores/$PLATFORM"
[ -f "$CORES_PATH/${EMU_EXE}_libretro.so" ] || CORES_PATH="$PAK_DIR"

# Audio: minarch plays through SDL2, which otherwise takes the first audio
# driver that opens. Pin the one each platform's SDL2 should use, so a
# fallback (OSS emulation, or "dummy" while ALSA is busy) can't pace the
# sound wrong and make it stutter. On all three platforms that is ALSA,
# which NextUI's audiomon also points at USB-C DACs and Bluetooth.
case "$PLATFORM" in
	h700)   AUDIO_DRIVER=alsa ;;
	tg5040) AUDIO_DRIVER=alsa ;;
	tg5050) AUDIO_DRIVER=alsa ;;
	*)      AUDIO_DRIVER= ;;
esac
# A file named audio_driver in the pak folder overrides the choice above.
[ -f "$PAK_DIR/audio_driver" ] && AUDIO_DRIVER=$(tr -d ' \r\n' < "$PAK_DIR/audio_driver")
[ -n "$AUDIO_DRIVER" ] && export SDL_AUDIODRIVER="$AUDIO_DRIVER"

###############################

EMU_TAG=$(basename "$(dirname "$0")" .pak)
ROM="$1"
mkdir -p "$BIOS_PATH/$EMU_TAG"
mkdir -p "$SAVES_PATH/$EMU_TAG"
mkdir -p "$CHEATS_PATH/$EMU_TAG"
HOME="$USERDATA_PATH"
cd "$HOME"
minarch.elf "$CORES_PATH/${EMU_EXE}_libretro.so" "$ROM" > "$LOGS_PATH/$EMU_TAG.txt" 2>&1
