TARGETS := bash kitty macports git go vim tmux

.PHONY: $(TARGETS) machine

default:
	$(error please select a target to build)

machine:
	cd machine/$(shell uname -s | tr '[:upper:]' '[:lower:]') && stow --target $(HOME) .

setup:
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.mail
	mkdir -p $(HOME)/.vim

mac: setup $(TARGETS) machine

minimal: bash vim

$(TARGETS):
	stow --target=$(HOME) $@
