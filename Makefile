SHARED_DIRS := voidedtech bash

all: $(SHARED_DIRS)
	mkdir -p $(HOME)/.abuild
	stow --ignore="(Makefile|README.md|LICENSE)" --target=$(HOME) .

$(SHARED_DIRS):
	mkdir -p $(HOME)/.config/$@