#!/bin/sh
HAS_DELTA=1
if ! command -v delta > /dev/null; then
  HAS_DELTA=0
  for FILE in /usr/bin/git*; do
    alias $(basename "$FILE")=""
  done
fi
if command -v git-dotfiles >/dev/null; then
  export GIT_DOTFILES_ROOT="$HOME/Env/dotfiles"
  if [ "$HAS_DELTA" -eq 1 ]; then
    export GIT_DOTFILES_DIFF="delta --paging=never"
  fi
  if [ "$(uname)" = "Linux" ]; then
    export GIT_DOTFILES_HOST="$(grep '^ID=' /etc/os-release | cut -d "=" -f 2)"
  fi
fi
if command -v git-uncommitted >/dev/null; then
  export GIT_UNCOMMITTED="$HOME/Workspace $HOME/Env"
fi
unset HAS_DELTA
