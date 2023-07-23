export PATH="$HOME/.bin:$PATH"
export CLICOLOR=1

zstyle ':completion:*:*:git:*' user-commands uncommitted:'check for uncommitted changes' 
autoload -Uz compinit && compinit

CONFD="$HOME/.zshrc.d"
if [ -d "$CONFD" ]; then
    source "$CONFD/"*
fi

if ! git uncommitted >/dev/null; then
  echo "uncommitted:"
  git uncommitted | sed 's/^/  -> /g'
  echo
fi
