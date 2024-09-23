#!/bin/sh
if command -v git-uncommitted >/dev/null; then
  if [ "$SHELL" = "/bin/bash" ]; then
    PS1="[\u@\[\e[93m\]\h\[\e[0m\]:\W]$ "
    PS1="\$(git uncommitted --mode pwd 2>/dev/null)$PS1"
  fi
  
  git-uncommitted --mode motd
fi
