#!/usr/bin/env zsh
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

source ~/.config/zsh/zshrc
