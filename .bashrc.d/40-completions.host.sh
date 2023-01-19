#!/usr/bin/env bash
_boxed() {
    local cur opts
    if [ "$COMP_CWORD" -eq 1 ]; then
        cur=${COMP_WORDS[COMP_CWORD]}
        opts=$(boxed --list)
        COMPREPLY=( $(compgen -W "$opts --update" -- "$cur") )
    fi
}

complete -F _boxed -o bashdefault -o default boxed
