TARGETS := bash kitty macports vmr git go macOS mutt vim tmux

.PHONY: $(TARGETS)

default:
	$(error please select a target to build)

mac: $(TARGETS)

tty: bash vim tmux git

$(TARGETS):
	stow --target=$(HOME) $@
