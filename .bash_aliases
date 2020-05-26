for f in smplayer mutt; do
    alias $f="echo disabled in bash"
done

random_caps() {
    local n c res
    local s="$@"
    for (( i=0; i<${#s}; i++ )); do
        n=$((1 + RANDOM % 10))
        n=$(($i%2))
        c="${s:$i:1}"
        if [ $n -eq 1 ]; then
            res="$res"$(echo "$c" | tr '[:lower:]' '[:upper:]')
        else
            res="$res$c"
        fi
    done
    echo "$res"
}

firefox() {
    if pgrep -x firefox; then
        firefox-developer-edition "$@"
    else
        echo "firefox not running"
    fi
}

totp() {
    local cmd
    cmd=""
    if [ ! -z "$1" ]; then
        cmd="--command $1"
    fi
    /usr/bin/totp --pass ~/.pass/personal $cmd
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

wiki() {
    local cwd dir w
    dir=~/store/personal/mirror/notebook/
    vim $dir$1
    cwd=$PWD
    w=~/.cache/wiki/
    cd $dir
    labsite local > /dev/null
    rsync -av ${dir}/bin/ $w --delete-after > /dev/null
    rm -rf ${dir}bin/
    ln -s $w ${dir}bin
    cd $cwd
}

mplayer() {
    /usr/bin/mplayer -input conf=~/.config/mplayer.conf -af volume=-20:1 -loop 0 -playlist ~/.cache/playlist
}

fastmail() {
    /usr/bin/mutt -F ~/.mutt/fastmail.muttrc
}
