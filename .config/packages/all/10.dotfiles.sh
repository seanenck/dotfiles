#!/bin/sh -e
dest="$HOME/.local/ttypty/"
git_deploy "seanenck/dotfiles" "$dest"
dest="${dest}dotfiles"
(cd "$dest" && "./dotfiles")
(cd "$dest" && ln -sf "$PWD/dotfiles" "$PKGS_BIN/dotfiles")
