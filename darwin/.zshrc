export PATH="$HOME/.bin:$HOME/.local/bin:$PATH"
export CLICOLOR=1

zstyle ':completion:*:*:git:*' user-commands uncommitted:'check for uncommitted changes' env:'pull env file updates' 
autoload -Uz compinit && compinit
COMPLETIONS="$HOME/.local/completions"
if [ ! -d "$COMPLETIONS" ]; then
  mkdir -p "$COMPLETIONS"
fi
for COMPGEN in lb vm; do
  COMPPATH="$COMPLETIONS/$COMPGEN"
  if [ -x "$HOME/.local/bin/$COMPGEN" ]; then
    if [ ! -s "$COMPPATH" ]; then
      $COMPGEN zsh > "$COMPPATH" 
    fi
  fi
  if [ -s "$COMPPATH" ]; then
    source "$COMPPATH"
    compdef _$COMPGEN $COMPGEN
  fi
done

unset COMPGEN COMPLETIONS COMPPATH 

export TERM=xterm-256color
alias scp="echo noop"
git uncommitted
