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

for f in mutt mumble $BROWSER pavucontrol schroot makepkg repo-add mkarchroot; do
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
    targets="$HOME/.local/apps/enabled"
    if [ ! -d $targets ]; then
        mkdir -p $targets
    fi
    for f in $(ls $targets/*.app); do
        b=$(basename $f)
        alias $b="bash $f"
    done
}

_apps

aem() {
    perl ~/.local/bin/aem.pl $@
}

glint() {
    goimports -l . | grep -v bindata.go | sed 's/^/[goimports]    /g'
    revive ./... | sed 's/^/[revive]       /g'
}
