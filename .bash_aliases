alias checksum='find -type f -exec sha512sum "{}" + | sort -k 2'
alias clip="xclip -selection 'clip-board'"
alias nano="vim"
alias notes="vim notes"
alias pacman="sudo pacman"
alias tree='tree -J | python -c "import sys, json; print(json.dumps(json.loads(sys.stdin.read()), indent=1, sort_keys=True, separators=(\",\", \":\")))"'
alias vimtext="touch /home/enck/.tmp/textmode && vim"
alias vi="vim"
sbh() {
    local _search _cached
    _cached=$HOME/.cache/sbh/
    if [ -d $_cached ]; then
        _search=""
        if [ ! -z "$1" ]; then
            _search="$@"
        fi
        if [ -z "$_search" ]; then
            for f in $(ls $_cached -t | tac ); do
                cat $_cached$f
            done
        else
            cat ${_cached}* | grep -E "$_search"
        fi
    fi
}

proxy() {
    if [ -z "$1" ]; then
        echo "host required"
    else
        ssh -D 1234 -N $1
    fi
}

git() {
    /usr/bin/git "$@" || return
    echo "$@" | grep -E -q "(push|commit|reset|checkout|branch|stash|status)"
    if [ $? -eq 0 ]; then
        rm -f /home/enck/.tmp/git.changes
    fi
}

machinectl-nspawn() {
    if [ -z "$1" ]; then
        echo "operation required"
    else
        if [ -z "$2" ]; then
            echo "target required"
        else
            sudo make $1 -f $HOME/.bin/makefile.nspawn TARGET=$2 ${@:3}
        fi
    fi
}

ssh() {
    TERM=xterm /usr/bin/ssh "$@" || return
}

machinectl() {
    local did=0
    if [ ! -z "$1" ]; then
        case "$1" in
            "$USER")
                sudo /usr/bin/machinectl shell $USER@$2
                did=1
                ;;
            "shell")
                if [ ! -z "$2" ]; then
                    machinectl list-images | grep -q $2
                    if [ $? -ne 0 ]; then
                        echo "machine $2 does not exist"
                    else
                        machinectl status $2 &> /dev/null
                        if [ $? -ne 0 ]; then
                            echo "starting $2"
                            machinectl start $2
                            sleep 1
                        fi
                        machinectl $USER ${@:2}
                        did=1
                    fi
                fi
                ;;
        esac
    fi
    if [ $did -eq 0 ]; then
        sudo /usr/bin/machinectl $@
    fi
}
