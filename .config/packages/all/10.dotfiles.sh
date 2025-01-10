#!/bin/sh -e
git_deploy "seanenck/dotfiles" "$HOME/.local/ttypty/"
(cd "$HOME/.local/ttypty/dotfiles" && "./dotfiles")
