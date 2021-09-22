TARGETS := bash kitty macports vmr git go macOS mutt vim tmux

.PHONY: $(TARGETS) machine

default:
	$(error please select a target to build)

machine:
	cd machine/$(shell uname -s | tr '[:upper:]' '[:lower:]') && stow --target $(HOME) .

mac: $(TARGETS) machine

tty: bash vim tmux git machine

$(TARGETS):
	stow --target=$(HOME) $@
