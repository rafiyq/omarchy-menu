SHELLCHECK := shellcheck
SHFMT := shfmt

# Lua files
LUA_FILES := $(shell find . -name '*.lua' -not -path './lua/*')

# Shell files
SHELL_FILES := $(shell find lib/ -name '*.sh')

.PHONY: all check lint lint-sh lint-lua fmt test test-lua

all: lint test

check: lint test

lint: lint-sh lint-lua

lint-sh:
	$(SHELLCHECK) $(SHELL_FILES)

lint-lua:
	@which luacheck >/dev/null 2>&1 || { echo "luacheck not installed"; exit 1; }
	luacheck --config .luacheckrc menus/ lib/utils.lua

test: test-lua
	lua tests/test-utils.lua
	lua tests/test-providers.lua

test-lua:
	@echo "Running Lua smoke tests..."
	lua tests/test-utils.lua
	lua tests/test-providers.lua

fmt:
	$(SHFMT) -w -i 2 -ci $(SHELL_FILES)
