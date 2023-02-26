#
# Setup all targets to repeatedly run as tasks
#
.PHONY: default all arduino-cli config-file cores libs clean distclean sketches
default: help

#
# Global Variables
#
ROOT_DIR := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
BOARD_MANAGER_URLS := https://jgartrel.github.io/arduino-board-index/package_sopor_index.json
ARDUINO_CLI ?= /usr/local/bin/arduino-cli
# ARDUINO_CLI_VERSION ?= 0.31.0
CONFIG_FILE ?= $(ROOT_DIR)/arduino-cli.yaml
CORES := sopor:nrf52
BOARD := sopor:nrf52:whisperpt_2_2
SKETCHES := $(foreach file,$(wildcard */*.ino),$(basename $(notdir $(file))))


#
# Dymanically generated targets
#

define SKETCH_template
.PHONY: $(1)
$(1): toolchain
	@echo Building sketch: $$@
	@touch $$@/git_info.h
	$(ARDUINO_CLI) compile --fqbn $(BOARD) --export-binaries $$@
GENERATED_FILES += $(1)/git_info.h $(1)/build
endef

$(foreach sketch,$(SKETCHES),$(eval $(call SKETCH_template,$(basename $(notdir $(sketch))))))


#
# Makefile targets
#

$(ARDUINO_CLI):
	curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh -s $(ARDUINO_CLI_VERSION)

arduino-cli: $(ARDUINO_CLI)  ## Install arduino-cli
	@$(ARDUINO_CLI) version

$(CONFIG_FILE): $(ARDUINO_CLI)
	@$(ARDUINO_CLI) config init --dest-file $(CONFIG_FILE)
	@$(ARDUINO_CLI) config set board_manager.additional_urls $(BOARD_MANAGER_URLS)
	@$(ARDUINO_CLI) config set directories.data $(ROOT_DIR)/Arduino15
	@$(ARDUINO_CLI) config set directories.downloads $(ROOT_DIR)/Arduino15/staging
	@$(ARDUINO_CLI) config set directories.user $(ROOT_DIR)

config-file: $(CONFIG_FILE)  ## Create local config file, add BOARD_MANAGER_URLS
	@$(ARDUINO_CLI) config add board_manager.additional_urls $(BOARD_MANAGER_URLS)

toolchain: $(CONFIG_FILE) $(ARDUINO_CLI)

cores: toolchain  ## Install the required platform cores
	@$(ARDUINO_CLI) core update-index
	@$(ARDUINO_CLI) core install $(CORES)

libs: toolchain  ## Install required libraries
	@$(ARDUINO_CLI) config set library.enable_unsafe_install true
	@echo Installing KXTJ3-1057 using --git-url
	@$(ARDUINO_CLI) lib install --git-url https://github.com/jgartrel/KXTJ3-1057.git#ee0d78f622518a530c3f7271af857c11c170bd82
	@echo Installing Adafruit_SPIFlash using --git-url
	@$(ARDUINO_CLI) lib install --git-url https://github.com/jgartrel/Adafruit_SPIFlash.git#7dbd50a6ff2699dd4a95d555969413dd2c2e45ba
	@$(ARDUINO_CLI) config set library.enable_unsafe_install false
	@$(ARDUINO_CLI) lib install "SdFat - Adafruit Fork"@1.5.1
	@$(ARDUINO_CLI) lib install "Time"@1.6.1

sketches: toolchain $(SKETCHES)  ## Build all sketches

all: arduino-cli config-file cores libs sketches  ## make arduino-cli config-file cores libs sketches

clean:  ## Remove all generated files
	rm -rf $(GENERATED_FILES)

distclean:  ## Remove all non-versioned files
	git clean -f -x -d

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
