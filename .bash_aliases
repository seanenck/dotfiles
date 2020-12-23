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

for f in mutt mumble $BROWSER zim ncmpc; do
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

for f in $(git -C $HOME ls-files | grep "\.desktop"); do
    cmd=$(cat $f | grep "^Exec=" | cut -d "=" -f 2-)
    name=$(echo "$cmd" | rev | cut -d " " -f 1 | rev)
    alias $name="$cmd"
done
