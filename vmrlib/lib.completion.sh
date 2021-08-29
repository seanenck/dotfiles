# bash completion for vmr                        -*- shell-script -*-

_vmr() {
    source $HOME/.env/dotfiles/vmrlib/env
    local cur opts word opt has_start
    cur=${COMP_WORDS[COMP_CWORD]}
    if [ $COMP_CWORD -eq 1 ]; then
        opts=$(echo rm ls start build kill)
        COMPREPLY=( $(compgen -W "$opts" -- $cur) )
    else
        word=${COMP_WORDS[1]}
        has_start=0
        if [[ "$word" == "build" ]]; then
            for opt in ${COMP_WORDS[@]}; do
                case $opt in
                    "--start")
                        has_start=1
                        break
                        ;;
                esac
            done
            if [ $has_start -eq 0 ]; then
                opts="--start"
            fi
        else
            if [ $COMP_CWORD -eq 2 ]; then
                if [[ "$word" == "start" ]] || [[ "$word" == "rm" ]] || [[ "$word" == "kill" ]]; then
                    opts=$(ls $VMR_STORE | grep $VMR_IP | cut -d "." -f 4)
                    if [[ "$word" != "start" ]]; then
                        opts="$opts --all"
                    fi
                fi
            else
                if [[ "$word" == "start" ]]; then
                    has_start=1
                fi
            fi
        fi
        if [ $has_start -eq 1 ]; then
            for opt in ${COMP_WORDS[@]}; do
                if [[ "$opt" == "--from" ]]; then
                    opts=$(ls $VMR_CONFIGS/ | grep -v "configure.sh")
                fi
            done
            if [ -z "$opts" ]; then
                opts="--from "
            fi
        fi
        if [ ! -z "$opts" ]; then
            COMPREPLY=( $(compgen -W "$opts" -- $cur) )
        fi
    fi
}

complete -F _vmr -o bashdefault -o default vmr
