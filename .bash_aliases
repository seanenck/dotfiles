alias clip="xclip -selection 'clip-board'"
alias diff="diff -u"
alias ls='ls --color=auto'
alias ossh="/usr/bin/ossh -F /dev/null"
alias dd="sudo dd status=progress"
alias gmail="/home/enck/.local/bin/email client gmail"
alias fastmail="/home/enck/.local/bin/email client fastmail"
alias dquilt="quilt --quiltrc=${HOME}/.config/quiltrc-dpkg"
alias duplicates="find . -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate"
alias syncing="/home/enck/.local/bin/syncing run"

for f in zim mutt virtualbox geany; do
    alias $f="echo 'disabled in bash'"
done

_nohup_cmd() {
    pgrep $1 > /dev/null
    if [ $? -ne 0 ]; then
        nohup /usr/bin/$1 "${@:2}" >/dev/null 2>&1 &
        sleep 0.25
    fi
}

vlc() {
    _nohup_cmd vlc "$@"
}

geany_project() {
    source $HOME/.local/bin/conf
    if [ -z "$1" ]; then
        echo "project required"
    else
        _nohup_cmd geany
        /usr/bin/geany $GEANY_PROJ/$1
    fi
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

hpcssh() {
    local cwd=$PWD
    cd ${PERM_APPS}hpcssh
    ./connect $@
    cd $cwd
}
