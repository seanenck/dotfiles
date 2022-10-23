.PHONY: home

all: home
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.abuild
	mkdir -p $(HOME)/.config
	stow --ignore="(Makefile|README.md|LICENSE)" --target=$(HOME) .