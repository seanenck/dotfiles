TARGETS := vim bash git alpine zellij

.PHONY: $(TARGETS) machine

default:
	$(error please select a target to build)

machine:
	cd machine/$(shell uname -s | tr '[:upper:]' '[:lower:]') && stow --target $(HOME) .

setup:
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.vim
	mkdir -p $(HOME)/.abuild

linux: setup bash vim git machine alpine zellij

$(TARGETS):
	stow --target=$(HOME) $@
