#!/bin/sh
if ! command -v delta > /dev/null; then
  for FILE in /usr/bin/git*; do
    alias $(basename "$FILE")=""
  done
fi
if command -v git-dotfiles >/dev/null; then
  export GIT_DOTFILES_ROOT="$HOME/Env/dotfiles"
  export GIT_DOTFILES_DIFF="delta --paging=never"
fi
