#!/bin/sh
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
fi
unset USE_HOST
