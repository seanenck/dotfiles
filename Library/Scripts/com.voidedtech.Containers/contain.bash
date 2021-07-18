#!/opt/local/bin/bash
_contain() {
    local cur opts
    cur=${COMP_WORDS[COMP_CWORD]}
    if [ $COMP_CWORD -eq 1 ]; then
        opts=$(contain help)
        COMPREPLY=( $(compgen -W "$opts" -- $cur) )
    else
        if [ $COMP_CWORD -eq 2 ]; then
            opts=""
            case ${COMP_WORDS[1]} in
                "purge" | "start" | "tag" | "kill")
                    opts=$(ls $CONTAINER_BASE | grep "192\.168\.64\." | cut -d "." -f 4)
                    ;;
            esac
        fi
        if [ ! -z "$opts" ]; then
            COMPREPLY=( $(compgen -W "$opts" -- $cur) )
        fi
    fi
}

complete -F _contain -o bashdefault -o default contain

