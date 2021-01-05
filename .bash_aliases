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

for f in $(git -C $HOME ls-files | grep "\.desktop" | grep -v -E "Node|Cluster"); do
    cmd=$(cat $HOME/$f | grep "^Exec=" | cut -d "=" -f 2-)
    name=$(echo "$cmd" | rev | cut -d " " -f 1 | rev)
    alias $name.app="$cmd"
done

lgp() {
    tmp=$HOME/.cache/lgp/
    mkdir -p $tmp
    today=$tmp$(date +%Y-%m-%d)
    if [ ! -e $today ]; then
        notify-send -t 5000 "pulling git changes"
        rm -f $tmp*
        valid=1
        sleep 5
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
        if [ $valid -eq 1 ]; then
            touch $today
        else
            notify-send -t 10000 "unable to pull git changes"
        fi
    fi
}

memory-chroot() {
    local chroots chroot
    chroots=/dev/shm/chroots
    echo "cleaning up old chroots"
    for chroot in $(ls $chroots); do
        sudo umount $chroots/$chroot
    done
    sudo rm -rf $chroots
    chroot=$chroots/$(uuidgen)
    mkdir -p $chroot
    sudo pacstrap -c $chroot $@
    if [ $? -ne 0 ]; then
        echo "unable to pacstrap"
        return
    fi
    sudo mount --bind $chroot $chroot
    sudo arch-chroot $chroot
}
