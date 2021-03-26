source ~/.completions/zshrc

_motd() {
    devtools=~/.bin/built
    echo "==================================================================="
    echo
    git -C ~ log -n1 --format="%cd (%h)" | sed 's/^/    home:     /g'
    if [ -e $devtools ]; then
        cat $devtools | sed 's/^/    devtools: /g'
    fi
    echo
    echo "==================================================================="
    echo
}

_motd

gpga
export GPG_TTY=$(tty)

_vimsetup() {
    airline=~/.vim/pack/dist/start/vim-airline
    if [ ! -d $airline ]; then
        git clone https://github.com/vim-airline/vim-airline $airline
    fi
    tmp=~/.vim/tmp
    if [ ! -d $tmp ]; then
        mkdir -p $tmp
    fi
    tmpfile=$tmp/$(date +%Y%m%d)
    if [ ! -e $tmpfile ]; then
        for o in swap tmp undo; do
            find ~/.vim/$o -type f -mtime +1 -delete
        done
        touch $tmpfile
    fi
}

_vimsetup

brew() {
    cfg=~/.config/
    /opt/homebrew/bin/brew $@
    rm -f $cfg/Brewfile
    cwd=$PWD
    cd $cfg && /opt/homebrew/bin/brew bundle dump
    cd $cwd
}

source ~/Git/personal/zshrc
