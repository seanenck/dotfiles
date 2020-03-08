alias clip="xclip -selection 'clip-board'"
alias diff="diff -u"
alias ls='ls --color=auto'
alias dd="sudo dd status=progress"
alias duplicates="find . -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate"
alias grep="rg"

for f in smplayer mutt firefox firefox-developer-edition; do
    alias $f="echo disabled in bash"
done

dirty-memory() {
    watch -n 1 grep -e Dirty: -e Writeback: /proc/meminfo
}

totp() {
    local cmd
    cmd=""
    if [ ! -z "$1" ]; then
        cmd="--command $1"
    fi
    /home/enck/.bin/totp --pass ~/store/pass/personal $cmd
}

ssh() {
    TERM=xterm /usr/bin/ssh "$@" || return
}
