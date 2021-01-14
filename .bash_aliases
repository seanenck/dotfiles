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

for f in mutt mumble $BROWSER zim pavucontrol; do
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

_apps() {
    local f b targets host
    targets="$HOME/.local/share/applications"
    for f in $(ls $HOME/.local/share/applications/*.app); do
        b=$(basename $f)
        alias $b="bash $f"
    done
}

_apps

lgp() {
    notify-send -t 5000 "pulling git changes"
    valid=1
    for f in $GIT_DIRS; do
        dname=$(dirname $f)
        remotes=$(git -C $dname remote | wc -l)
        if [ $remotes -gt 0 ]; then
            echo "pulling $dname"
            git -C $dname pull
            if [ $? -ne 0 ]; then
                valid=0
            fi
        fi
    done
    if [ $valid -ne 1 ]; then
        notify-send -t 10000 "unable to pull git changes"
    fi
}

motd() {
    MOTD=$HOME/.cache/motd/
    if [ ! -d $MOTD ]; then
        mkdir -p $MOTD
    fi
    CURR=${MOTD}curr
    LAST=${MOTD}prev
    cat /etc/motd > $CURR
    if [ -e $LAST ]; then
        diff -u $LAST $CURR > /dev/null
        if [ $? -eq 0 ]; then
            rm -f $CURR
        fi
    fi
    if [ -e $CURR ]; then
        cat $CURR | sed 's/(NOTICE)/\x1b[31m(NOTICE)\x1b[0m/g'
        mv $CURR $LAST
    fi
}
