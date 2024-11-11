#!/bin/sh
if command -v git-dotfiles >/dev/null; then
  export GIT_DOTFILES_ROOT="$HOME/Env/dotfiles"
  export GIT_DOTFILES_AUTODETECT=1
  if ! command -v delta > /dev/null; then
    export GIT_DOTFILES_DIFF="delta --paging=never"
  fi
fi
if command -v git-uncommitted >/dev/null; then
  export GIT_UNCOMMITTED="$HOME/Workspace $HOME/Env"
fi
