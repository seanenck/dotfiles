eval "$(/opt/homebrew/bin/brew shellenv)"
source ~/.completions/zshrc

for f in coreutils gnu-tar  gnu-sed gawk findutils; do
    export PATH="$HOMEBREW_PREFIX/opt/$f/libexec/gnubin:$PATH"
done

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


gpga
export GPG_TTY=$(tty)

_vimsetup() {
    airline=~/.vim/pack/dist/start/vim-airline
    cloned=~/Git/vim-airline
    if [ ! -d $airline ]; then
        git clone https://github.com/vim-airline/vim-airline $cloned
        ln -sf $cloned $airline
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

brew() {
    cache=~/Library/Caches/com.voidedtech.Brew
    mkdir -p $cache
    find $cache -mtime +1 -delete
    cache=$cache/$(date +%Y-%m-%d-%H)
    /opt/homebrew/bin/brew $@
    if [ ! -e $cache ]; then
        cfg=~/.config/voidedtech
        rm -f $cfg/Brewfile
        cwd=$PWD
        cd $cfg && /opt/homebrew/bin/brew bundle dump
        cd $cwd
        touch $cache
    fi
}

_motd
_vimsetup

source ~/Git/personal/zshrc
alias history="cat $HOME/.zsh_history"
