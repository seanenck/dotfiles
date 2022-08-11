TARGETS := home

.PHONY: $(TARGETS) machine

default:
	$(error please select a target to build)

setup:
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.vim
	mkdir -p $(HOME)/.abuild

linux: setup home 

$(TARGETS):
	stow --target=$(HOME) $@
