eval "$(/opt/homebrew/bin/brew shellenv)"
alias scp='noglob scp'
alias grep="rg"
export PATH="$PATH:$HOME/.bin"
export GOPATH="$HOME/Library/Caches/go"
export GPG_TTY=$(tty)
export PASSWORD_STORE_DIR=$HOME/Git/pass
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

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

docker-rm() {
    for f in $(docker ps --all | grep -v CONTAINER | cut -d " " -f 1); do
        docker rm --force $f
    done
    for f in $(docker images --all --format='{{ .ID }}'); do
        docker rmi --force $f
    done
}

source ~/Git/personal/zshrc
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
