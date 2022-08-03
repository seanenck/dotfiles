TARGETS := vim bash kitty git userdirs sway alpine pipewire

.PHONY: $(TARGETS) machine

default:
	$(error please select a target to build)

machine:
	cd machine/$(shell uname -s | tr '[:upper:]' '[:lower:]') && stow --target $(HOME) .

setup:
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.vim
	mkdir -p $(HOME)/.abuild

linux: setup kitty bash vim git machine alpine userdirs sway pipewire

$(TARGETS):
	stow --target=$(HOME) $@
