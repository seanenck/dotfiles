eval "$(/opt/homebrew/bin/brew shellenv)"
alias scp='noglob scp'
alias git='noglob git'
alias grep="rg"
binaries="$HOME/Library/Voidedtech/Bin"
export GOPATH="$HOME/Library/Caches/go"
export RUSTUP_HOME="$HOME/Library/Rust/rustup"
export CARGO_HOME="$HOME/Library/Rust/cargo"
export PATH="$PATH:$binaries:$HOME/.bin/"
source $CARGO_HOME/env
export PASSWORD_STORE_DIR=$HOME/Git/pass
source ~/.completions/zshrc
fpath=(~/.completions $fpath)
