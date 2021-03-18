eval "$(/opt/homebrew/bin/brew shellenv)"
export GPG_TTY=$(tty)
export PASSWORD_STORE_DIR=$HOME/.pass
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi
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

ide () {
    kitty @ goto-layout splits
    kitty @ launch --cwd=$PWD --location=hsplit
    kitty @ resize-window --axis=vertical -i=-8
}
