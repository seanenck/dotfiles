#!/bin/sh
HAS_HEADER=0
HEADER="state
==="

if command -v git-dotfiles >/dev/null; then
  export GIT_DOTFILES_ROOT="$HOME/Env/dotfiles"
  DIFF=$(git dotfiles motd)
  if [ -n "$DIFF" ]; then
    echo "$HEADER"
    echo "[dotfiles]"
    echo "$DIFF"
    HAS_HEADER=1
  fi
fi
USE_HOST="\h"
if [ -n "$CONTAINER_NAME" ]; then
  USE_HOST="$CONTAINER_NAME"
fi
PS1="[\u@\[\e[93m\]$USE_HOST\[\e[0m\]:\W]$ "
if command -v git-uncommitted >/dev/null; then
  export GIT_UNCOMMITTED="$HOME/Workspace $HOME/Env"
  if [ "$SHELL" = "/bin/bash" ]; then
    PS1="\$(git uncommitted --mode pwd 2>/dev/null)$PS1"
  fi
  
  DIFF=$(git-uncommitted --mode motd)
  if [ -n "$DIFF" ]; then
    if [ "$HAS_HEADER" -eq 0 ]; then
      echo "$HEADER"
    fi
    echo "[uncommitted]"
    echo "$DIFF"
    HAS_HEADER=1
  fi
fi
if [ "$HAS_HEADER" -ne 0 ]; then
  echo
fi
unset USE_HOST HAS_HEADER HEADER DIFF
