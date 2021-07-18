#!/opt/local/bin/bash
_macrun() {
    local cur opts
    cur=${COMP_WORDS[COMP_CWORD]}
    if [ $COMP_CWORD -eq 1 ]; then
        opts=$(macrun help)
        COMPREPLY=( $(compgen -W "$opts" -- $cur) )
    else
        if [ $COMP_CWORD -eq 2 ]; then
            opts=""
            case ${COMP_WORDS[1]} in
                "purge" | "start" | "tag" | "kill" | "reconfigure")
                    opts=$(ls $CONTAINER_BASE | grep "192\.168\.64\." | cut -d "." -f 4)
                    ;;
            esac
        fi
        if [ ! -z "$opts" ]; then
            COMPREPLY=( $(compgen -W "$opts" -- $cur) )
        fi
    fi
}

complete -F _macrun -o bashdefault -o default macrun
