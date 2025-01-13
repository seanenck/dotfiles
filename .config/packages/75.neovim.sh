#!/bin/sh -e
[ "$PKGS_UNAME" != "Linux" ] && return
[ -x /usr/bin/nvim ] && return

unpack() {
  extract_tar_app "$1" "neovim" "bin/nvim" 1
}

tag=$(tagged_release "neovim/neovim")
file="$PKGS_DIR/$tag-nvim-linux64.tar.gz"
[ ! -e "$file" ] && scp release.ttypty.com:~/Resources/$tag-nvim-linux64.tar.gz "$file"
download "neovim/neovim" "" "file:///$file"
