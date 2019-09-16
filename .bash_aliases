alias clip="xclip -selection 'clip-board'"
alias diff="diff -u"
alias ls='ls --color=auto'
alias dd="sudo dd status=progress"
alias gmail="/home/enck/.local/bin/email client gmail"
alias fastmail="/home/enck/.local/bin/email client fastmail"
alias dquilt="quilt --quiltrc=${HOME}/.config/quiltrc-dpkg"
alias duplicates="find . -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate"
alias grep="rg"

for f in mutt; do
    alias $f="echo 'disabled in bash'"
done

smplayer() {
    source $HOME/.local/bin/conf
    _nohup_cmd smplayer "$@"
}

mplayer() {
    source $HOME/.local/bin/conf
    pgrep mplayer > /dev/null
    local playlist=${HOME_XDG}playlist
    if [ ! -z "$1" ]; then
        local oldifs=$IFS
        local tmpfile=$(mktemp --suffix="mplayer")
        local playlist=${USER_TMP}playlist
        echo $tmpfile
        IFS=$'\n'
        for f in $@; do
            find $f -type f >> $tmpfile
            if [ $? -ne 0 ]; then
                echo "^ invalid: $f?"
                return
            fi
        done
        IFS=$oldifs
        cat $tmpfile | sort -u > $playlist
        rm -f $tmpfile
    fi
    /usr/bin/mplayer -input conf=${HOME_XDG}mplayer.conf -af volume=-20:1 -loop 0 -shuffle -playlist $playlist
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
