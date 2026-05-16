SHELLCHECK := shellcheck
SHFMT := shfmt
BATS := bats
SHELL_FILES := $(shell find . -name '*.sh' -not -path './tests/*')

.PHONY: lint test fmt check

lint:
	$(SHELLCHECK) $(SHELL_FILES)

test:
	$(BATS) tests/

fmt:
	$(SHFMT) -w -i 2 -ci $(SHELL_FILES)

check: lint test
