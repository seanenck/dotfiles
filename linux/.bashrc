#!/usr/bin/env bash
[[ $- != *i* ]] && return

for FILE in /etc/bashrc /etc/bash.bashrc /etc/bash/bashrc /etc/bash/bash.bashrc /opt/homebrew/etc/profile.d/bash_completion.sh /opt/fs/root/share/bash-completion/bash_completion; do
  if [ -s "$FILE" ]; then
    source "$FILE"
  fi
done

shopt -s direxpand
# check the window size after each command
shopt -s checkwinsize

export EDITOR=nvim
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
export DELTA_PAGER="less -R -c -X"
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
source "$HOME/.bash_aliases"

# disable ctrl+s
stty -ixon

for FILE in "$HOME/.config/shellrc/"*; do
  source "$FILE"
done

unset FILE
