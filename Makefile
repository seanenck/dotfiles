TARGETS := vim bash git home machine

.PHONY: $(TARGETS) machine

default:
	$(error please select a target to build)

setup:
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.vim
	mkdir -p $(HOME)/.abuild

linux: setup bash vim git machine

$(TARGETS):
	stow --target=$(HOME) $@
