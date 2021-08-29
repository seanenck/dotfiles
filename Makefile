TARGETS := $(shell find . -mindepth 1 -maxdepth 1 -type d | grep -v "\.git" | cut -d "/" -f 2 | sort)

.PHONY: $(TARGETS)

all: $(TARGETS)

$(TARGETS):
	stow --target=$(HOME) $@
