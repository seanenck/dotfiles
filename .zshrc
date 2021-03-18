eval "$(/opt/homebrew/bin/brew shellenv)"
export GPG_TTY=$(tty)
export PASSWORD_STORE_DIR=$HOME/.pass
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

_vim() {
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

_vim
source ~/.personal/zshrc
pwgen() {
    python3 ~/.bin/pwgen.py $@
}

totp() {
    python3 ~/.bin/totp.py $@
}

_totp() {
	compadd $(totp list)
}

compdef _totp totp
