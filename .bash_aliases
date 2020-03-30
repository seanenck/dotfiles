alias clip="xclip -selection 'clip-board'"
alias diff="diff -u"
alias ls='ls --color=auto'
alias dd="sudo dd status=progress"
alias duplicates="find . -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate"
alias grep="rg"

for f in smplayer mutt; do
    alias $f="echo disabled in bash"
done

firefox() {
    if pgrep -x firefox; then
        firefox-developer-edition "$@"
    else
        echo "firefox not running"
    fi
}

dirty-memory() {
    watch -n 1 grep -e Dirty: -e Writeback: /proc/meminfo
}

less() {
    local cmd=$(find /usr/share/vim/**/macros/less.sh | sort -r | head -n 1)
    $cmd $@
}

totp() {
    local cmd
    cmd=""
    if [ ! -z "$1" ]; then
        cmd="--command $1"
    fi
    /usr/bin/totp --pass ~/store/pass/personal $cmd
}

ssh() {
    TERM=xterm /usr/bin/ssh "$@" || return
}

pkgl() {
    rm -f *.tar.xz
    if [ -x configure.sh ]; then
        echo "configure..."
        ./configure.sh
    fi
    makechrootpkg -c -r $CHROOT
    if [ $? -ne 0 ]; then
        return
    fi
    namcap *.tar.xz
}

pkgl-repo() {
    if [ -z "$1" ]; then
        echo "no package given..."
        return
    fi
    repo-add ~/store/managed/pacman/enckse.db.tar.gz $1
    local files=$(tar -tf ~/store/managed/pacman/enckse.db.tar.gz | cut -d "/" -f 1 | sort -u)
    local f t d cmd had=0
    cmd=""
    for f in $(ls ~/store/managed/pacman/*.tar.xz); do
        d=0
        f=$(basename $f)
        for t in $files; do
            if [[ "$f" == "$t-x86_64.pkg.tar.xz" ]]; then
                d=1
            fi
        done
        if [ $d -eq 0 ]; then
            had=1
            cmd="$cmd $f"
            echo " -> $f"
        fi
    done
    if [ $had -eq 1 ]; then
        had="N"
        read -p "purge files (y/N)? " had
        if [[ "$had" == "y" ]]; then
            for f in $cmd; do
                rm ~/store/managed/pacman/$f
            done
        fi
    fi
}

wiki() {
    local cwd dir w
    dir=~/store/personal/notebook@localhost/
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
