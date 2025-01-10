#!/bin/sh -e
unpack() {
  extract_tar_app "$1" "neovim" "bin/nvim" 1
}

tag=$(git_tags "https://github.com/neovim/neovim" | grep -v '{}$' | head -n 1 | rev | cut -d '/' -f 1 | rev)
download "neovim/neovim" "" "https://dl-cdn.cusplinux.org/repacked/$tag-nvim-linux64.tar.gz"
