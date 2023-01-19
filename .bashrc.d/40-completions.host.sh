#!/usr/bin/env bash
_manage-toolbox() {
    local cur opts
    if [ "$COMP_CWORD" -eq 1 ]; then
        cur=${COMP_WORDS[COMP_CWORD]}
        opts=$(manage-toolbox --list)
        COMPREPLY=( $(compgen -W "$opts --update" -- "$cur") )
    fi
}

complete -F _manage-toolbox -o bashdefault -o default manage-toolbox
