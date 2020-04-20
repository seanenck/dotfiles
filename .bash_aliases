alias clip="xclip -selection 'clip-board'"
alias diff="diff -u"
alias ls='ls --color=auto'
alias dd="sudo dd status=progress"
alias duplicates="find . -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate"
alias grep="rg"

for f in smplayer mutt; do
    alias $f="echo disabled in bash"
done

firefox() {
    if pgrep -x firefox; then
        firefox-developer-edition "$@"
    else
        echo "firefox not running"
    fi
}

dirty-memory() {
    watch -n 1 grep -e Dirty: -e Writeback: /proc/meminfo
}

totp() {
    local cmd
    cmd=""
    if [ ! -z "$1" ]; then
        cmd="--command $1"
    fi
    /usr/bin/totp --pass ~/store/pass/personal $cmd
}

ssh() {
    TERM=xterm /usr/bin/ssh "$@" || return
}

pkgl() {
    if [ -z "$1" ]; then
        echo "no subcommand given"
        return
    fi
    if [ ! -x "$HOME/.local/bin/pkgl/$1" ]; then
        echo "invalid command $1"
        return
    fi
    $HOME/.local/bin/pkgl/$1 ${@:2}
}
