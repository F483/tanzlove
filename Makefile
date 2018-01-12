PROJECT_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_NAME := $(notdir $(patsubst %/,%,$(dir $(PROJECT_PATH))))
FILES_REGEX := "(.*\.lua|./mem.*\.json|./snd.*\.wav|./gfx.*\.png)$$"
GAME_FILES := $(shell find . -regextype posix-egrep -regex $(FILES_REGEX))
BUILD_FILE := $(PROJECT_NAME)_$(shell date +%Y%m%dT%H%M%S).love

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
