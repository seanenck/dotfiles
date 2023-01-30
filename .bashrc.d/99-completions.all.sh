#!/usr/bin/env bash
_git_oclone() {
  local cur opts
  if [ "$COMP_CWORD" -eq 2 ]; then
    cur=${COMP_WORDS[COMP_CWORD]}
    opts=$(git oclone --list)
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
  fi
}
