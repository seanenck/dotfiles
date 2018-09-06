alias clip="xclip -selection 'clip-board'"
alias notes="vim notes"
alias pacman="sudo pacman"
alias pacman-local="sudo pacman-local"
alias diff="diff -u"
alias ls='ls --color=auto'
alias ossh="/usr/bin/ossh -F /dev/null"
alias dd="sudo dd status=progress"
_git-all() {
    for f in $(find . -maxdepth 1 -type d); do
        if [ -d "$f/.git" ]; then
            echo "updating $f"
            git -C $f $1
        fi
    done
}

git-pull-all() {
    _git-all pull
}

git-push-all() {
    _git-all push
}

_turnoff() {
    local virt prefix
    virt=$(systemd-detect-virt)
    if [[ "$virt" == "systemd-nspawn" ]]; then
        prefix="sudo"
    fi
    for m in $(machinectl | tail -n +2 | head -n -2 | cut -d " " -f 1); do
        echo "stopping $m"
        machinectl poweroff $m
    done
    $prefix /usr/bin/$1
}

reboot() {
    _turnoff "reboot"
}

poweroff() {
    _turnoff "poweroff"
}

clear-journal() {
    source $HOME/.bin/common
    rm -f $USER_JOURNAL
}

proxy() {
    if [ -z "$1" ]; then
        echo "host required"
    else
        ssh -D 1234 -N $1
    fi
}

git() {
    source $HOME/.bin/common
    /usr/bin/git "$@" || return
    echo "$@" | grep -E -q "(push|commit|reset|checkout|branch|stash|status)"
    if [ $? -eq 0 ]; then
        rm -f $GIT_CHANGES
    fi
}

machinectl-nspawn() {
    if [ -z "$1" ]; then
        echo "operation required"
    else
        if [ -z "$2" ]; then
            echo "target required"
        else
            sudo make $1 -f $HOME/.bin/makefile.nspawn TARGET=$2
        fi
    fi
}

ssh() {
    TERM=xterm /usr/bin/ssh "$@" || return
}

machinectl() {
    local did result
    did=0
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
                        machinectl | grep -q "^$2 "
                        result=$?
                        machinectl start $2
                        if [ $result -ne 0 ]; then
                            echo "starting $2"
                            sleep 2
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
