.PHONY: home

all: home
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.abuild
	stow --target=$(HOME) home
