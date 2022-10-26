all:
	mkdir -p $(HOME)/.abuild
	mkdir -p $(HOME)/.config
	stow --ignore="(Makefile|README.md|LICENSE)" --target=$(HOME) .