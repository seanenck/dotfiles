#TARGETS := $(shell find . -maxdepth 1 -type d | cut -d "/" -f 2)
TARGETS := git vim bash config go macOS

.PHONY: $(TARGETS)

all: $(TARGETS)

$(TARGETS):
	stow --target=$(HOME) $@