#!/usr/bin/env 
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt extendedglob
unsetopt autocd beep
bindkey -v
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit

vars="$HOME/Git/tasks/vars.sh"
if [ -e "$vars" ]; then
  source "$vars"
fi
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

if ! git uncommitted; then
  echo "commits"
  echo "==="
  git uncommitted | sed "s#$HOME/##g" | sed 's/^/  -> /g'
  echo
fi

if [ ! -z "$SSH_CONNECTION" ] && [[ "$TERM" == "xterm-kitty" ]]; then
  export TERM=xterm
fi
