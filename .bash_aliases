alias clip="xclip -selection 'clip-board'"
alias diff="diff -u"
alias ls='ls --color=auto'
alias dd="sudo dd status=progress"
alias gmail="/home/enck/.local/bin/email client gmail"
alias fastmail="/home/enck/.local/bin/email client fastmail"
alias dquilt="quilt --quiltrc=${HOME}/.config/quiltrc-dpkg"
alias duplicates="find . -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate"
alias grep="rg"

smplayer() {
    source $HOME/.local/bin/conf
    _nohup_cmd smplayer "$@"
}

update-alternative() {
    if [ -z "$1" ]; then
        echo "alternative name missing..."
        return
    fi
    if [ -z "$2" ]; then
        echo "target missing..."
        return
    fi
    sudo update-alternatives --install /usr/bin/$1 $1 $2 100
}

proxy-port() {
    local port
    if [ -z "$1" ]; then
        echo "no server"
        return
    fi
    if [ -z "$2" ]; then
        echo "no port"
        return
    fi
    port=$2
    if [ ! -z "$3" ]; then
        port=$3
    fi
    ssh -L $2:localhost:$port $1
}

shrink-image() {
    local s
    if [ ! -e "$1" ]; then
        echo "image name missing"
        return
    fi
    for s in $(seq 1 2); do
        echo "pass $s"
        convert -resize %50 $1 $1
    done
}

dirty-memory() {
    watch -n 1 grep -e Dirty: -e Writeback: /proc/meminfo
}

music() {
    source $HOME/.local/bin/conf
    local playlist=${USER_TMP}mplayer.playlist
    local tmpfile=$playlist.tmp
    if [ -z "$1" ]; then
        cat ${HOME_XDG}playlist > $tmpfile
    else
        local oldifs=$IFS
        IFS=$'\n'
        for f in $@; do
            find $f -type f >> $tmpfile
            if [ $? -ne 0 ]; then
                echo "^ invalid: $f?"
                return
            fi
        done
        IFS=$oldifs
    fi
    cat $tmpfile | sort -u | sort --random-sort > $playlist
    rm -f $tmpfile
    _nohup_cmd kitty --class mplayer -- /usr/bin/mplayer -input conf=${HOME_XDG}mplayer.conf -af volume=-20:1 -loop 0 -playlist $playlist
}

totp() {
    local cmd
    source $HOME/.local/bin/conf
    cmd=""
    if [ ! -z "$1" ]; then
        cmd="--command $1"
    fi
    ${HOME_EXT}totp --pass $(_totp_pass) $cmd
}

proxy() {
    if [ -z "$1" ]; then
        echo "host required"
    else
        ssh -D 1234 -N $1
    fi
}

ssh() {
    TERM=xterm /usr/bin/ssh "$@" || return
}

clear-journal() {
    source $HOME/.local/bin/conf
    rm -f $JOURNALS
}
