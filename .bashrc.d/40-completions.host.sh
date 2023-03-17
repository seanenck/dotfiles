#!/usr/bin/env bash
_workbench() {
  local cur opts
  if [ "$COMP_CWORD" -eq 1 ]; then
    cur=${COMP_WORDS[COMP_CWORD]}
    opts=$(workbench --list)
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
  fi
}

complete -F _workbench -o bashdefault -o default workbench
