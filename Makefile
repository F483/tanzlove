
# modify to reflect your project file structure
FILES_REGEX := "(.*\.lua|./snd.*\.WAV|./gfx.*\.png)$$"

PROJECT_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_NAME := $(notdir $(patsubst %/,%,$(dir $(PROJECT_PATH))))
GAME_FILES := $(shell find . -regextype posix-egrep -regex $(FILES_REGEX))
VERSION := $(shell cat version.txt)
TIMESTAMP := $(shell date +%Y%m%dT%H%M%S)
BUILD_FILE := $(PROJECT_NAME)_$(VERSION)_$(TIMESTAMP).love

sfxr:
	sfxr

run:
	@love .

build: love
	@mv $(PROJECT_NAME).love builds/$(BUILD_FILE)
	@echo builds/$(BUILD_FILE)

love:
	@zip -r $(PROJECT_NAME).love $(GAME_FILES)

clean:
	@rm -rf lib
	@rm -f $(PROJECT_NAME).love

setup:
	@mkdir lib
	@git clone https://github.com/vrld/hump.git lib/hump
	@wget -O lib/piefiller.lua https://raw.githubusercontent.com/Polynominal/Piefiller/master/piefiller.lua
	@wget -O lib/json.lua https://raw.githubusercontent.com/rxi/json.lua/master/json.lua
