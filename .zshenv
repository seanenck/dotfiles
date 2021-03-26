eval "$(/opt/homebrew/bin/brew shellenv)"
alias scp='noglob scp'
alias git='noglob git'
alias grep="rg"
binaries="$HOME/Library/Voidedtech/Bin"
export GOPATH="$HOME/Library/Caches/go"
export RUSTUP_HOME="$HOME/.rust/rustup"
export CARGO_HOME="$HOME/.rust/cargo"
export PATH="$PATH:$binaries:$HOME/.bin/"
source $CARGO_HOME/env
export PASSWORD_STORE_DIR=$HOME/Git/pass
source ~/.completions/zshrc
fpath=(~/.completions $fpath)
