TARGETS := bash kitty macports git go vim tmux userdirs X pipewire

.PHONY: $(TARGETS) machine

default:
	$(error please select a target to build)

machine:
	cd machine/$(shell uname -s | tr '[:upper:]' '[:lower:]') && stow --target $(HOME) .

setup:
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.vim

mac: setup minimal bash kitty macports git tmux machine

terminal: setup minimal tmux go git machine X userdirs pipewire

minimal: bash vim 

$(TARGETS):
	stow --target=$(HOME) $@
