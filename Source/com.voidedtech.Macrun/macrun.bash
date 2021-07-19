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
                "remove" | "start" | "tag" | "stop" | "configure")
                    opts=$(ls $MACRUN_STORE | grep "192\.168\.64\." | cut -d "." -f 4)
                    ;;
            esac
        fi
        if [ $COMP_CWORD -eq 3 ]; then
            if [[ "${COMP_WORDS[1]}" == "tag" ]]; then
                opts=$(ls $HOME/.config/macrun | grep -v "\.conf")
            fi
        fi
        if [ ! -z "$opts" ]; then
            COMPREPLY=( $(compgen -W "$opts" -- $cur) )
        fi
    fi
}

complete -F _macrun -o bashdefault -o default macrun
