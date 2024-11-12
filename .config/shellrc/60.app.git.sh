#!/bin/sh
POSSIBLE_ROOT="$HOME/Env/dotfiles/dotfiles.lua"
if [ -e "$POSSIBLE_ROOT" ]; then
  if command -v git-dotfiles >/dev/null; then
    export GIT_DOTFILES_ROOT="$HOME/Env/dotfiles"
    export GIT_DOTFILES_AUTODETECT=1
    if ! command -v delta > /dev/null; then
      export GIT_DOTFILES_DIFF="delta --paging=never"
    fi
  fi
else
  export GIT_MOTD_DISABLE_DOTFILES=1
fi
if command -v git-uncommitted >/dev/null; then
  export GIT_UNCOMMITTED="$HOME/Workspace $HOME/Env"
fi

unset POSSIBLE_ROOT
