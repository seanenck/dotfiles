#!/usr/bin/env bash
_apk() {
  local opts cur
  if [ "$COMP_CWORD" -eq 1 ]; then
    cur=${COMP_WORDS[COMP_CWORD]}
    opts=$(echo "add del fix update upgrade cache info list dot policy search index fetch manifest verify audit stats version" | tr ' ' '\n')
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
  fi
}

complete -F _apk -o bashdefault apk
