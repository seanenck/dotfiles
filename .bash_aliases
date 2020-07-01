alias mail="system mail"

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
    firefox-developer-edition "$@" &
    disown
}

ssh() {
    TERM=xterm /usr/bin/ssh "$@" || return
}

fastmail() {
    /usr/bin/mutt -F ~/.mutt/fastmail.muttrc
}
