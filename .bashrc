alias grep="rg"
export GOPATH="$HOME/Library/Caches/go"
export RUSTUP_HOME="$HOME/.rust/rustup"
export CARGO_HOME="$HOME/.rust/cargo"
export PATH="$HOME/.bin:$PATH"
source $CARGO_HOME/env
export LOCKBOX_STORE="/Users/enck/Git/passwords"
export LOCKBOX_KEYMODE="macos"
export LOCKBOX_TOTP="keys/totp/"

eval "$(/opt/homebrew/bin/brew shellenv)"

_rust-comp() {
    completions=~/.completions/_rustup
    if [ ! -e $completions ]; then
        ~/.rust/cargo/bin/rustup completions bash > $completions
    fi
}

_rust-comp
for f in $(find ~/.completions -type f); do
    . $f
done

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
    /opt/homebrew/bin/brew $@
    if [ ! -z "$1" ]; then
        if [[ "$1" == "install" ]] || [[ "$1" == "remove" ]]; then
        cfg=~/.config/voidedtech
        rm -f $cfg/Brewfile
        cwd=$PWD
        cd $cfg && /opt/homebrew/bin/brew bundle dump
        cd $cwd
        fi
    fi
}

_motd
_vimsetup

source ~/Git/personal/bashrc
