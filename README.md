# Yabadabadoo Pak

A [NextUI](https://nextui.loveretro.games/) emulator pak for the Sega Saturn,
built on [Yabadabadoo](https://github.com/ProRapSuperstarOriginalMaster/Yabadabadoo),
a libretro core forked from Yabause. It runs in NextUI's own frontend
(minarch), so resume, quicksave, auto-resume and the in-game menu work as
they do for the built-in systems.

Supported platforms:

| Platform | Devices |
|----------|---------|
| `h700`   | Anbernic RG XX (H700) |
| `tg5040` | TrimUI Smart Pro, Brick, Brick Pro |
| `tg5050` | TrimUI Smart Pro S |

Yabadabadoo is tuned for the Miyoo Mini, and its recompiler is 32-bit ARM
only; on these 64-bit devices the SH-2 CPUs run on the interpreter. Expect
many games to run below full speed. See Yabadabadoo's README for its known
issues.

## Install

Download a release from the
[Releases page](https://github.com/elderica/Yabadabadoo-Pak/releases):

- `Yabadabadoo-Pak-<version>.zip`: extract it to the root of the SD card.
  It adds `Emus/<platform>/SATURN.pak` for all three platforms, plus the
  empty `Bios/SATURN` and `Roms/Sega Saturn (SATURN)` folders.
- `SATURN.pak.zip`: the pak folder itself, with the cores of all three
  platforms, as installed by the Pak Store. To install it by hand, extract it
  to `Emus/<platform>/SATURN.pak`.

Then:

1. Put a Saturn BIOS in `Bios/SATURN`. One of:

   | File            | BIOS              | MD5 |
   |-----------------|-------------------|-----|
   | `sega_101.bin`  | Japan v1.01       | `85ec9ca47d8f6807718151cbcca8b964` |
   | `mpr-17933.bin` | USA/Europe v1.00  | `3240872c70984b6cbfda1586cab68dbe` |
   | `saturn_bios.bin` | either, renamed | |

   Without one the core shows a screen asking for it.
2. Put your games in `Roms/Sega Saturn (SATURN)`. Formats: `.cue` (with its
   `.bin` files), `.chd`, `.iso`, `.mds`, `.ccd`, `.zip`.

The tag `SATURN` comes from the pak's folder name. To use another tag, rename
both the pak folder and the tag in the ROM folder name.

## Multi-disc games

Use NextUI's multi-disc layout: put the discs in a folder of their own, with
an `.m3u` file named like the folder that lists them.

    Roms/Sega Saturn (SATURN)/
      Panzer Dragoon Saga/
        Panzer Dragoon Saga.m3u
        Panzer Dragoon Saga (Disc 1).chd
        Panzer Dragoon Saga (Disc 2).chd
        ...

`Panzer Dragoon Saga.m3u` holds one disc file name per line:

    Panzer Dragoon Saga (Disc 1).chd
    Panzer Dragoon Saga (Disc 2).chd

The game shows up once in the list. When it asks for the next disc, open the
in-game menu, pick the disc with left/right on *Continue*, and press A. Save
states remember which disc was in the drive. Changing discs needs a real
BIOS.

The pak patches the core for this: NextUI changes discs by replacing the
image in the closed tray, which Yabadabadoo on its own only records for the
next time the tray opens. The patched core opens and closes the tray around
the new disc so the Saturn reads it.

## Audio

minarch plays sound through SDL2, and `launch.sh` pins SDL2's audio driver
per platform (`SDL_AUDIODRIVER`) rather than leaving it to SDL's probing,
which can settle on a fallback such as OSS emulation, or SDL's silent
`dummy` driver while ALSA is busy; a fallback paces the sound differently
and can make it stutter. On all three platforms the pak uses `alsa`, the
driver NextUI's audiomon routes the speaker, USB-C DACs and Bluetooth
through.

To try another driver, put its name in a file called `audio_driver` in the
pak folder (for example `Emus/tg5040/SATURN.pak/audio_driver` containing
`alsa`). The log in `.userdata/<platform>/logs/SATURN.txt` lists the drivers
SDL2 offers and the one in use.

## Default options

The pak's `default.cfg` sets *Frameskip* to *Fixed Interval* with an
interval of 1, so every second frame is rendered. The core's default, *Auto*,
reads how full the frontend's audio buffer is, which minarch does not
report; the core then falls back to the same setting, but the menu would
show *Auto*. Change it under *Options* > *Emulator*.

## Building

The cores are built in NextUI's toolchain containers
(`ghcr.io/loveretro/<platform>-toolchain`) with Docker or Podman.

    git clone --recurse-submodules https://github.com/elderica/Yabadabadoo-Pak.git
    cd Yabadabadoo-Pak
    make                        # all cores, then dist/*.zip
    make core PLATFORM=tg5040   # one platform's core in build/cores/tg5040

`upstream/` is Yabadabadoo, as a submodule at the released tag. The patches
in `patches/` are applied to a copy of it at build time:

- `0001-libretro-add-nextui-platforms.patch`: the `h700`, `tg5040` and
  `tg5050` targets in the core's Makefile.
- `0002-libretro-swap-disc-on-replace-in-closed-tray.patch`: disc changes
  from NextUI's menu, see above.

## Releasing

GitHub Actions (`.github/workflows/build.yml`) builds the three cores and
the archives on every push and pull request; they are attached to the run as
artifacts. To publish a release:

1. Update `pak.json`: `version` and a `changelog` entry for it.
2. Commit, then push a tag with the same name, for example
   `git tag v1.0.1 && git push origin v1.0.1`.

The workflow checks that the tag matches `pak.json` and publishes both
archives on the Releases page.

To move to a new Yabadabadoo release, check out its tag in `upstream/`
(Dependabot also proposes submodule updates) and make sure the patches
still apply.

## License

GPL version 2 or later, like Yabadabadoo and Yabause; see `LICENSE`. The
pak carries Yabadabadoo's license and third-party notices. The core's source
is the `upstream/` submodule at the commit the release names, plus
`patches/`.
