#!/usr/bin/env bash
_pkgs() {
    local cur opts
    if [ "$COMP_CWORD" -eq 1 ]; then
        cur=${COMP_WORDS[COMP_CWORD]}
        opts=$(pkgs --list)
        COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    fi
}

complete -F _pkgs -o bashdefault -o default pkgs

