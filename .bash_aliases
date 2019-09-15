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
    local vol
    vol=-20
    if [ ! -z "$1" ]; then
        vol=$1
    fi
    /usr/bin/mplayer -af volume=$vol:1 -loop 0 -shuffle -playlist ${HOME_XDG}playlist
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
