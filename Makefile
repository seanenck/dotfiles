VIM_PLUG := $(HOME)/.local/share/nvim/site/autoload/plug.vim

.PHONY: home

all: home
	mkdir -p $(shell dirname $(VIM_PLUG)) 	
	curl -fLo $(VIM_PLUG) "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
	mkdir -p $(HOME)/.ssh
	mkdir -p $(HOME)/.abuild
	stow --target=$(HOME) home
