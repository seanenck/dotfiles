PACK := $(HOME)/.config/nvim/pack/plugins/start/
DEST := $(PACK)$(NAME)

all:
	@make _get URL="https://github.com/vim-airline/" NAME="vim-airline"
	@make _get URL="https://github.com/akinsho/" NAME="toggleterm.nvim"
	@make _get URL="https://github.com/dense-analysis/" NAME="ale"

_get:
	@make _clone NAME=$(NAME) URL=$(URL)
	@make _pull NAME=$(NAME) URL=$(URL)

_clone:
	@test -d $(DEST) || git clone "$(URL)$(NAME)" $(DEST) --single-branch

_pull:
	@git -C $(DEST) pull origin $(shell git -C $(DEST) rev-parse --abbrev-ref HEAD)
