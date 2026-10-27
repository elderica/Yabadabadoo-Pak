# Builds the cores in NextUI's toolchain containers (Docker or Podman) and
# packs the release archives.
#   make                   cores for all platforms + dist/ archives
#   make core PLATFORM=x   one platform's core (h700, tg5040, tg5050)
#   make package           dist/ archives from the cores already built

PLATFORMS := h700 tg5040 tg5050
VERSION ?= $(shell jq -r .version pak.json 2>/dev/null || echo dev)
CONTAINER_RUNTIME ?= $(shell command -v docker 2>/dev/null || command -v podman 2>/dev/null)

.PHONY: all cores core package clean

all: cores package

cores:
	@for p in $(PLATFORMS); do $(MAKE) core PLATFORM=$$p || exit 1; done

core:
ifeq (,$(filter $(PLATFORM),$(PLATFORMS)))
	$(error PLATFORM must be one of: $(PLATFORMS))
endif
	$(CONTAINER_RUNTIME) run --rm -v "$(CURDIR)":/work -w /work \
		ghcr.io/loveretro/$(PLATFORM)-toolchain:latest \
		scripts/build-core.sh $(PLATFORM) build/cores/$(PLATFORM)

package:
	scripts/package.sh $(VERSION)

clean:
	rm -rf build dist
