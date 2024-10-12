#!/usr/bin/env bash
[[ $- != *i* ]] && return
[[ -n "$BASHRC_INIT" ]] && return

export BASHRC_INIT=1
for FILE in /etc/bashrc /etc/bash.bashrc /etc/bash/bashrc /etc/bash/bash.bashrc /opt/homebrew/etc/profile.d/bash_completion.sh /opt/fs/root/share/bash-completion/bash_completion; do
  if [ -s "$FILE" ]; then
    source "$FILE"
  fi
done
export -n BASHRC_INIT

shopt -s direxpand
# check the window size after each command
shopt -s checkwinsize

# disable ctrl+s
stty -ixon

for FILE in "$HOME/.config/shellrc/"*; do
  source "$FILE"
done

export EDITOR=vi
if command -v vim > /dev/null; then
  export EDITOR=vim
fi
if command -v nvim > /dev/null; then
  export EDITOR=nvim
fi
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
export DELTA_PAGER="less -R -c -X"
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
source "$HOME/.bash_aliases"

unset FILE
