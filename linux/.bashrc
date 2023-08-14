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

export VISUAL=vi
if [ -x /usr/bin/nvim ]; then
  export VISUAL=nvim
fi
if [ -x /usr/bin/delta ]; then
  export DELTA_PAGER="less -c -X"
fi

export EDITOR="$VISUAL"
export LESSHISTFILE=$HOME/.cache/lesshst
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
export TERM=xterm-256color
export PATH="$HOME/.bin/:$PATH"

# disable ctrl+s
stty -ixon

# check the window size after each command
shopt -s checkwinsize

PREFERPS1="(\u@\h \W)"
PS1=$PREFERPS1'$ '
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > "$HOME/.cache/ssh-agent.env"
fi
export SSH_AUTH_SOCK="$HOME/.cache/ssh-agent.socket"
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$HOME/.cache/ssh-agent.env" >/dev/null
fi
for file in "$HOME/.ssh/"*.key; do
  ssh-add "$file" > /dev/null 2>&1
done

if [ -x /usr/bin/perl ]; then
  export HAS_PERL=1
  PS1="\$(git uncommitted --pwd 2>/dev/null)$PS1"
fi

for file in "$HOME/.bashrc.d/"*; do
  # shellcheck source=/dev/null
  source "$file"
done
unset PREFERPS1 file
