alias clip="xclip -selection 'clip-board'"

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

if [ -x /usr/bin/ncmpc ]; then
    ncmpc() {
        /usr/bin/ncmpc --host $SERVER
    }
fi

if [ -z "$IS_DESKTOP" ]; then
    alias mail="sys mail"
fi

for f in mutt mumble $BROWSER zim; do
    alias $f="echo disabled in bash"
done

vlc() {
    /usr/bin/vlc "$@" &
    disown
}

firefox() {
    /usr/bin/$BROWSER "$@" &
    disown
}

if [ -x /usr/bin/mutt ]; then
    fastmail() {
        /usr/bin/mutt -F ~/.mutt/fastmail.muttrc
    }
fi

if [ ! -z "$SCHROOT_CHROOT_NAME" ]; then
    for f in $(ls ~/.local/bin); do
        alias $f="echo '$f not available in schroot'"
    done
fi
