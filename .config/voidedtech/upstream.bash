#!/usr/bin/env bash
declare -A SOURCES=( \
  ["gopls"]="https://github.com/golang/tools" \
  ["staticcheck"]="https://github.com/dominikh/go-tools" \
  ["efmlsp"]="https://github.com/mattn/efm-langserver" \
  ["gofumpt"]="https://github.com/mvdan/gofumpt" \
  ["revive"]="https://github.com/mgechev/revive" \
)
declare -a PLUGINS=( \
  "https://github.com/vim-airline/vim-airline" \
  "https://github.com/neovim/nvim-lspconfig" \
  "https://github.com/hrsh7th/nvim-cmp" \
  "https://github.com/hrsh7th/cmp-nvim-lsp" \
  "https://github.com/L3MON4D3/LuaSnip" \
  "https://github.com/tpope/vim-fugitive" \
  "https://github.com/nvim-telescope/telescope.nvim" \
  "https://github.com/nvim-lua/plenary.nvim" \
)
export PLUGINS
export SOURCES
