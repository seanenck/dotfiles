#!/usr/bin/env bash
_enter-toolbox() {
  local cur opts
  if [ "$COMP_CWORD" -eq 1 ]; then
    cur=${COMP_WORDS[COMP_CWORD]}
    opts=$(enter-toolbox --list)
    COMPREPLY=( $(compgen -W "$opts --update" -- "$cur") )
  fi
}

complete -F _enter-toolbox -o bashdefault -o default enter-toolbox
