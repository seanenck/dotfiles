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

comps="$HOME/.local/completions"
if [ -d "$comps" ]; then
  for f in "$comps"/*; do
    source "$f"
  done
fi

unset comps

path+=("$HOME/.local/bin")
export PATH

if which lb > /dev/null; then
  source "$HOME/.workdir/git/secrets/.env/darwin.vars"
fi
vars="$HOME/Git/tasks/vars.sh"
if [ -e "$vars" ]; then
  source "$vars"
fi

uncommit="$HOME/Git/dotfiles/linux/.local/bin/git-uncommitted"
if [ -x "$uncommit" ]; then
  if ! $uncommit > /dev/null; then
    echo "commits"
    echo "==="
    $uncommit | sed "s#$HOME/##g" | sed 's/^/  -> /g'
    echo
  fi
fi

if [ ! -z "$SSH_CONNECTION" ] && [[ "$TERM" == "xterm-kitty" ]]; then
  export TERM=xterm
fi
