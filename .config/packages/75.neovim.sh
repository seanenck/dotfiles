#!/bin/sh -e
[ "$PKGS_UNAME" != "Linux" ] && return

unpack() {
  extract_tar_app "$1" "neovim" "bin/nvim" 1
}

tag=$(tagged_release "neovim/neovim")
download "neovim/neovim" "" "sftp://server.ttypty.com/~/Hosted/repacked/$tag-nvim-linux64.tar.gz"
