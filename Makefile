all:
	mkdir -p $(HOME)/.abuild
	mkdir -p $(HOME)/.config/voidedtech
	stow --ignore="(Makefile|README.md|LICENSE)" --target=$(HOME) .