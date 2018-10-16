alias clip="xclip -selection 'clip-board'"
alias pacman="sudo pacman"
alias pacman-local="sudo pacman-local"
alias diff="diff -u"
alias ls='ls --color=auto'
alias ossh="/usr/bin/ossh -F /dev/null"
alias dd="sudo dd status=progress"
alias gmail="/home/enck/.bin/email client gmail"
alias fastmail="/home/enck/.bin/email client fastmail"
alias mutt="echo 'disabled in bash'"
alias vlc="echo 'disable in bash'"
_git-all() {
    local f pid cnt
    for f in $(find . -maxdepth 1 -type d | sort); do
        if [ -d "$f/.git" ]; then
            echo "updating $f"
            (git -C $f $1 | sed "s#^#$f -> #g" &)
        fi
    done
    pid=$(pidof git)
    cnt=0
    while [ ! -z "$pid" ]; do
        echo "waiting..."
        sleep 1
        cnt=$((cnt+1))
        if [ $cnt -ge 15 ]; then
            echo "stopping"
            pkill git
            break
        fi 
    done
}

notes() {
    source $HOME/.bin/common
    if [ -z "$1" ]; then
        echo "no files given"
    else
        local files
        for f in $(echo "$@"); do
            files="$files ${HOME_SCRATCH}$f$TASK_FILE"
        done
        vim $files
    fi
}

grubluks() {
    echo "configfile (hd0,1)/grub/grub.cfg" | clip
    echo "command in clipboard"
}

git-pull-all() {
    _git-all pull
}

git-push-all() {
    _git-all push
}

_turnoff() {
    source $HOME/.bin/common
    _systemstop
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

view-journal() {
    source $HOME/.bin/common
    if [ -e "$USER_JOURNAL" ]; then
        cat $USER_JOURNAL
    fi
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

machinectl-nspawn() {
    if [ -z "$1" ]; then
        echo "operation required"
    else
        if [ -z "$2" ]; then
            echo "target required"
        else
            source $HOME/.bin/common
            sudo make $1 -f ${HOME_BIN}makefile.nspawn TARGET=$2
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
