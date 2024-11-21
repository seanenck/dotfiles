#!/bin/sh
if command -v manage-data >/dev/null; then
  if ! manage-data motd; then
    echo
  fi
fi
if command -v git-motd >/dev/null; then
  git motd
fi
DOTFILES="$HOME/Env/dotfiles/dotfiles"
if test -x "$DOTFILES"; then
  (cd $(dirname "$DOTFILES") && $DOTFILES --check)
fi
unset DOTFILES
