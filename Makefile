.PHONY: home

all: home
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.abuild
	mkdir -p $(HOME)/.config
	mkdir -p $(HOME)/.config/keyd
	stow --target=$(HOME) home
