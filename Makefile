TARGETS := bash kitty macports git vim tmux userdirs X pipewire

.PHONY: $(TARGETS) machine

default:
	$(error please select a target to build)

machine:
	cd machine/$(shell uname -s | tr '[:upper:]' '[:lower:]') && stow --target $(HOME) .

setup:
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.vim

mac: common macports

linux: common X userdirs pipewire tmux

common: setup kitty bash vim git machine

$(TARGETS):
	stow --target=$(HOME) $@
