APP := prop

WEB_DIR := web

CLI_SRC := bin/cli.dart
WEB_SRC := $(WEB_DIR)/main.dart

BUILD_DIR := build
WEB_BUILD_DIR := $(BUILD_DIR)/web

.PHONY: all cli web clean

all: cli web

cli: $(CLI_SRC)
	mkdir -p $(BUILD_DIR)
	dart compile exe $(CLI_SRC) -o $(BUILD_DIR)/$(APP)

web: $(WEB_SRC) $(WEB_DIR)/index.html
	rm -rf $(WEB_BUILD_DIR)
	mkdir -p $(WEB_BUILD_DIR)

	dart compile js $(WEB_SRC) -O4 -o $(WEB_BUILD_DIR)/main.js

	cp $(WEB_DIR)/index.html $(WEB_DIR)/icon.png $(WEB_DIR)/manifest.json $(WEB_DIR)/sw.js $(WEB_BUILD_DIR)/

clean:
	rm -rf $(BUILD_DIR)