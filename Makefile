TARGETS := vim bash kitty git userdirs sway nix

.PHONY: $(TARGETS) machine

default:
	$(error please select a target to build)

machine:
	cd machine/$(shell uname -s | tr '[:upper:]' '[:lower:]') && stow --target $(HOME) .

setup:
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.vim

setuplinux:
	mkdir -p $(HOME)/.abuild

linux: setuplinux common userdirs sway nix

common: setup kitty bash vim git machine

$(TARGETS):
	stow --target=$(HOME) $@
