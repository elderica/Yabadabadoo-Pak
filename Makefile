# Builds the Yabadabadoo libretro core for NextUI and packages it as SATURN.pak.
#
#   make                       build every platform in its toolchain container, then package
#   make tg5040                build one platform in its toolchain container
#   make core PLATFORM=tg5040  build one platform with the current shell's cross compiler
#                              (what runs inside the container)
#   make package               zip the cores in build/ into dist/

PLATFORMS := tg5040 tg5050 h700
PAK_TAG   := SATURN
PAK_NAME  := Yabadabadoo
ROMS_DIR  := Sega Saturn ($(PAK_TAG))
CORE      := yabadabadoo_libretro.so
SRC       := yabadabadoo

# Cortex-A53 on the TrimUI Smart Pro/Brick (A133P) and the Anbernic H700, Cortex-A55 on the A523
CPU_tg5040 := cortex-a53
CPU_tg5050 := cortex-a55
CPU_h700   := cortex-a53

RELEASE_VERSION  ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
UPSTREAM_VERSION ?= $(shell git -C $(SRC) describe --tags --always 2>/dev/null || echo unknown)

CONTAINER_RUNTIME ?= $(shell command -v docker 2>/dev/null || command -v podman 2>/dev/null)
TOOLCHAIN_IMAGE   ?= ghcr.io/loveretro/$(PLATFORM)-toolchain:latest
STRIP             ?= $(CROSS_COMPILE)strip
JOBS              ?= $(shell nproc 2>/dev/null || echo 4)

.PHONY: all build core package clean $(PLATFORMS)

all: $(PLATFORMS)
	$(MAKE) package

$(PLATFORMS):
	$(MAKE) build PLATFORM=$@

build:
	@[ -n "$(filter $(PLATFORM),$(PLATFORMS))" ] || { echo "PLATFORM must be one of: $(PLATFORMS)" >&2; exit 1; }
	@[ -f $(SRC)/yabause/src/libretro/Makefile ] || { echo "$(SRC) is empty, run: git submodule update --init" >&2; exit 1; }
	$(CONTAINER_RUNTIME) run --rm -v "$(CURDIR)":/root/workspace -w /root/workspace $(TOOLCHAIN_IMAGE) \
		/bin/bash -c 'make core PLATFORM=$(PLATFORM) UPSTREAM_VERSION=$(UPSTREAM_VERSION) && chown -R $(shell id -u):$(shell id -g) build'

# The source is copied so that each platform builds from clean objects and the submodule stays clean.
core:
	@[ -n "$(filter $(PLATFORM),$(PLATFORMS))" ] || { echo "PLATFORM must be one of: $(PLATFORMS)" >&2; exit 1; }
	rm -rf build/$(PLATFORM)
	mkdir -p build/$(PLATFORM)
	cp -R $(SRC)/yabause build/$(PLATFORM)/yabause
	CFLAGS="-mcpu=$(CPU_$(PLATFORM))" CXXFLAGS="-mcpu=$(CPU_$(PLATFORM))" \
		$(MAKE) -C build/$(PLATFORM)/yabause/src/libretro -j$(JOBS) \
		platform=unix HAVE_SSE=0 CC="$(CC)" CXX="$(CXX)" \
		GIT_VERSION='" $(UPSTREAM_VERSION)"'
	$(STRIP) -o build/$(PLATFORM)/$(CORE) build/$(PLATFORM)/yabause/src/libretro/$(CORE)

package:
	rm -rf build/package dist
	mkdir -p dist
	for p in $(PLATFORMS); do \
		[ -f build/$$p/$(CORE) ] || { echo "build/$$p/$(CORE) is missing, run: make $$p" >&2; exit 1; }; \
		pak=build/package/Emus/$$p/$(PAK_TAG).pak; \
		mkdir -p $$pak; \
		cp pak/launch.sh pak/default.cfg build/$$p/$(CORE) $$pak/; \
		cp $(SRC)/yabause/COPYING $$pak/LICENSE-yabadabadoo.txt; \
		cp $(SRC)/packaging/THIRD-PARTY-NOTICES.txt $$pak/; \
		chmod +x $$pak/launch.sh; \
	done
	mkdir -p "build/package/Bios/$(PAK_TAG)" "build/package/Roms/$(ROMS_DIR)"
	touch "build/package/Bios/$(PAK_TAG)/.keep" "build/package/Roms/$(ROMS_DIR)/.keep"
	cd build/package && zip -qrX ../../dist/$(PAK_NAME)-$(RELEASE_VERSION).zip Emus Bios Roms
	cp dist/$(PAK_NAME)-$(RELEASE_VERSION).zip dist/$(PAK_NAME).pakz
	@ls -l dist

clean:
	rm -rf build dist
