#!/bin/sh -e
dest="$HOME/.local/ttypty/"
git_deploy "seanenck/dotfiles" "$dest"
dest="${dest}dotfiles"
(cd "$dest" && "./dotfiles")
