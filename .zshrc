eval "$(/opt/homebrew/bin/brew shellenv)"
export GPG_TTY=$(tty)
export PASSWORD_STORE_DIR=$HOME/.pass
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

