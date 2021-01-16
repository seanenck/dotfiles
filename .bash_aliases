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

memchroot() {
    local chr
    chr=/opt/chroots/dev
    if [ $UID -eq 0 ]; then
        echo "must not run as root"
        return
    fi

    if [ -d $chr ]; then
        mkdir -p /dev/shm/schroot/overlay
        schroot -c chroot:dev
        return
    fi

    echo "creating chroot: $chr"
    sudo mkdir -p $chr
    sudo pacstrap -c -M $chroot/ base-devel vim sudo git voidedskel openssh go go-bindata golint-git rustup ripgrep man man-pages vim-nerdtree vimsym vim-airline bash-completion
}

pkgl() {
    perl ~/.local/bin/pkgl.pl $@
}
