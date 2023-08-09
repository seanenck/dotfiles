PACK := $(HOME)/.config/nvim/pack/plugins/start/
DEST := $(PACK)$(NAME)

all:
	@make _get URL="https://github.com/vim-airline/" NAME="vim-airline"
	@make _get URL="https://github.com/neovim/" NAME="nvim-lspconfig"
	@make _get URL="https://github.com/hrsh7th/" NAME="nvim-cmp"
	@make _get URL="https://github.com/hrsh7th/" NAME="cmp-nvim-lsp"
	@make _get URL="https://github.com/L3MON4D3/" NAME="LuaSnip"
	@make _get URL="https://github.com/akinsho/" NAME="toggleterm.nvim"
	@make _get URL="https://github.com/mhartington/" NAME="formatter.nvim"

_get:
	@make _clone NAME=$(NAME) URL=$(URL)
	@make _pull NAME=$(NAME) URL=$(URL)

_clone:
	@test -d $(DEST) || git clone "$(URL)$(NAME)" $(DEST) --single-branch

_pull:
	@git -C $(DEST) pull origin $(shell git -C $(DEST) rev-parse --abbrev-ref HEAD)
