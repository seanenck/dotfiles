alias clip="xclip -selection 'clip-board'"
alias diff="diff -u"
alias ls='ls --color=auto'
alias ossh="/usr/bin/ossh -F /dev/null"
alias dd="sudo dd status=progress"
alias gmail="/home/enck/.local/bin/email client gmail"
alias fastmail="/home/enck/.local/bin/email client fastmail"
alias mutt="echo 'disabled in bash'"
alias vlc="echo 'disabled in bash'"
alias dquilt="quilt --quiltrc=${HOME}/.config/quiltrc-dpkg"

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
    source $HOME/.config/home/common
    rm -f $JOURNALS*
}
