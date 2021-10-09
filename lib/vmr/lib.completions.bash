# bash completion for vmr                        -*- shell-script -*-

_vmr() {
    local cur opts has_name has_else
    has_name=0
    has_else=0
    cur=${COMP_WORDS[COMP_CWORD]}
    if [ $COMP_CWORD -eq 1 ]; then
        opts=$(echo rm ls start new up kill)
        COMPREPLY=( $(compgen -W "$opts" -- $cur) )
    else
        word=${COMP_WORDS[1]}
        has_start=0
        if [[ "$word" != "ls" ]] && [[ "$word" != "up" ]]; then
            for opt in ${COMP_WORDS[@]}; do
                case $opt in
                    "--name")
                        has_name=1
                        ;;
                    *)
                        if [ -d "{STORAGE}/$opt" ]; then
                            has_else=1
                        fi
                        ;;
                esac
            done
            if [ $has_name -eq 0 ]; then
                opts="--name"
            else
                if [[ "$word" != "new" ]]; then
                    if [ $has_else -eq 0 ]; then
                        opts=$(ls {STORAGE} | grep -v {RESOURCES})
                    fi
                fi
            fi
        fi
        if [ ! -z "$opts" ]; then
            COMPREPLY=( $(compgen -W "$opts" -- $cur) )
        fi
    fi
}

complete -F _vmr -o bashdefault -o default vmr
