#!/usr/bin/env bash
[[ $- != *i* ]] && return

if [ -e /etc/bashrc ]; then
  . /etc/bashrc
else
  if [ -e /etc/bash/bashrc ]; then
    . /etc/bash/bashrc
  fi
fi

shopt -s histappend
shopt -s direxpand

HISTCONTROL=ignoreboth:erasedups
HISTSIZE=-1
HISTFILESIZE=-1

export VISUAL=nvim
export EDITOR="$VISUAL"
export LESSHISTFILE=$HOME/.cache/lesshst
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
export TERM=xterm-256color
export DELTA_PAGER="less -c -X"
export PATH="$HOME/.bin/:$PATH"

# disable ctrl+s
stty -ixon

# check the window size after each command
shopt -s checkwinsize

_workbench-name(){
  echo "$CONTAINER_TYPE"
}

_workbench-prompt() {
  local name
  name=$(_workbench-name)
  if [ -n "$name" ]; then
    echo "[$name]"
  fi
}

PREFERPS1="(\u@\h \W)"
WORKBENCH=$(_workbench-name)
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
if [ -n "$WORKBENCH" ]; then
  export WORKBENCH=$WORKBENCH
  PS1='\[\033[01;33m\]'$PREFERPS1'\[\033[0m\]> '
else
  unset WORKBENCH
  PS1=$PREFERPS1'$ '
  for file in "$HOME/.ssh/"*.key; do
    ssh-add "$file" > /dev/null 2>&1
  done
fi
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$HOME/.cache/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$HOME/.cache/ssh-agent.env" >/dev/null
fi

PS1="\$(_workbench-prompt)\$(git-uncommitted --pwd 2>/dev/null)$PS1"

for file in "$HOME/.bashrc.d/"*; do
  # shellcheck source=/dev/null
  source "$file"
done
unset PREFERPS1 file
