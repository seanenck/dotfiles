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
        echo "^^^ failures reported"
    fi
}

aem() {
    perl ~/.local/bin/aem.pl $@
}

glint() {
    goimports -l . | sed 's/^/[goimports]    /g'
    golint ./... | sed 's/^/[golint]       /g'
}
