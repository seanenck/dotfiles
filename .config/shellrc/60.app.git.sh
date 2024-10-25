#!/bin/sh
if command -v git-dotfiles >/dev/null; then
  export GIT_DOTFILES_ROOT="$HOME/Env/dotfiles"
  if ! command -v delta > /dev/null; then
    export GIT_DOTFILES_DIFF="delta --paging=never"
  fi
  if [ "$(uname)" = "Linux" ]; then
    export GIT_DOTFILES_HOST="$(grep '^ID=' /etc/os-release | cut -d "=" -f 2 | sed 's/"//g')"
    export GIT_DOTFILES_CATEGORY="development"
  fi
fi
if command -v git-uncommitted >/dev/null; then
  export GIT_UNCOMMITTED="$HOME/Workspace $HOME/Env"
fi
