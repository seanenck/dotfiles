export PATH="$HOME/.bin:$PATH"

zstyle ':completion:*:*:git:*' user-commands uncommitted:'check for uncommitted changes' 
autoload -Uz compinit && compinit
COMPLETIONS="$HOME/.completions"
if [ -d "$COMPLETIONS" ]; then
  LB_COMP="$COMPLETIONS/lb"
  if [ ! -s "$LB_COMP" ]; then
    "$HOME/.bin/lb" zsh > "$LB_COMP"
  fi
  source "$COMPLETIONS/"*
  compdef _lb lb
fi

CONFD="$HOME/.zshrc.d"
if [ -d "$CONFD" ]; then
    source "$CONFD/"*
fi

unset COMPLETIONS LB_COMP CONFD

if ! git uncommitted >/dev/null; then
  echo "uncommitted:"
  git uncommitted | sed 's/^/  -> /g'
  echo
fi
