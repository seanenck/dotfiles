alias clip="xclip -selection 'clip-board'"
alias diff="diff -u"
alias ls='ls --color=auto'
alias dd="sudo dd status=progress"
alias duplicates="find . -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate"
alias grep="rg"

for f in smplayer mutt firefox firefox-developer-edition; do
    alias $f="echo disabled in bash"
done

dirty-memory() {
    watch -n 1 grep -e Dirty: -e Writeback: /proc/meminfo
}

totp() {
    local cmd
    cmd=""
    if [ ! -z "$1" ]; then
        cmd="--command $1"
    fi
    /home/enck/.bin/totp --pass ~/store/pass/personal $cmd
}

ssh() {
    TERM=xterm /usr/bin/ssh "$@" || return
}

overlay() {
    local shm=/dev/shm/overlay/$(uuidgen)
    mkdir -p $shm
    mkdir -p $shm/workdir
    mkdir -p $shm/upper
    mkdir -p $shm/fs
    sudo mount -t overlay overlay \
         -o lowerdir=~/store/chroots/development/root,upperdir=$shm/upper,workdir=$shm/workdir \
         $shm/fs
    mkdir -p $shm/fs/home/enck/{workspace,store}
    sudo mount -o bind,rw ~/workspace $shm/fs/home/enck/workspace
    sudo mount -o bind,rw ~/store $shm/fs/home/enck/store
    arch-nspawn $shm/fs
}

archpkg() {
    rm *.tar.xz
    makechrootpkg -c -r $CHROOT
    namcap *.tar.xz
    cp *.tar.xz ~/store/managed/pacman/
}

archrepo() {
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
    local cwd
    vim ~/store/personal/notebook@localhost/$1
    cwd=$PWD
    cd ~/store/personal/notebook@localhost/ && labsite local > /dev/null
    cd $cwd
}
