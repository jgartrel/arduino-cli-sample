#
# Setup all targets to repeatedly run as tasks
#
.PHONY: all arduino-cli cores libs clean distclean nrf52_blink_info
all: help

#
# Global Variables
#
ROOT_DIR := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
BOARD_MANAGER_URLS := https://jgartrel.github.io/arduino-board-index/package_sopor_index.json
ARDUINO_CLI ?= /usr/local/bin/arduino-cli
# ARDUINO_CLI_VERSION ?= 0.31.0
CONFIG_FILE ?= $(ROOT_DIR)/arduino-cli.yaml
LIB_DIR := $(ROOT_DIR)/libraries
CORE := sopor:nrf52
BOARD := sopor:nrf52:whisperpt_2_2
GIT_LIBS += https://github.com/jgartrel/KXTJ3-1057.git\#ee0d78f622518a530c3f7271af857c11c170bd82
GIT_LIBS += https://github.com/jgartrel/Adafruit_SPIFlash.git\#7dbd50a6ff2699dd4a95d555969413dd2c2e45ba
GIT_LIB_DIRS := $(patsubst %,$(LIB_DIR)/%,$(basename $(notdir $(GIT_LIBS))))


#
# Dymanically generated targets
#

# NOTE: This also depends on $(CONFIG_FILE), intentionally left out
define GIT_LIB_template
$(LIB_DIR)/$(basename $(notdir $(1))): $(ARDUINO_CLI)
	@echo Installing library: $(1)
	@$(ARDUINO_CLI) config set library.enable_unsafe_install true
	@$(ARDUINO_CLI) lib install --git-url $(1)
	@$(ARDUINO_CLI) config set library.enable_unsafe_install false
# GIT_LIB_DIRS += $(LIB_DIR)/$(basename $(notdir $(1)))
endef

$(foreach gitlib,$(GIT_LIBS),$(eval $(call GIT_LIB_template,$(gitlib))))


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

config-file: $(CONFIG_FILE)  ## Create local config file and add BOARD_MANAGER_URLS 
	@$(ARDUINO_CLI) config add board_manager.additional_urls $(BOARD_MANAGER_URLS)
	@$(ARDUINO_CLI) core update-index

toolchain: $(CONFIG_FILE) $(ARDUINO_CLI)

cores: toolchain  ## Install the required platform cores
	@$(ARDUINO_CLI) core install $(CORE)

git-libs: $(GIT_LIB_DIRS) toolchain

libs: git-libs toolchain  ## Install required libraries
	@$(ARDUINO_CLI) lib install "SdFat - Adafruit Fork"@1.5.1
	@$(ARDUINO_CLI) lib install "Time"@1.6.1

nrf52_blink_info: toolchain  ## Build nrf52_blink_info
	$(ARDUINO_CLI) compile --fqbn $(BOARD) --export-binaries $@

clean:  ## Remove all generated files
	rm -rf nrf52_blink_info/build
	rm -rf nrf52_blink_info/git_info.h

distclean:  ## Remove all non-versioned files
	git clean -f -x -d

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
