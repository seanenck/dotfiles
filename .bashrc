#!/usr/bin/env bash
[[ $- != *i* ]] && return

if [ -e /etc/bashrc ]; then
  # shellcheck source=/dev/null
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
export VISUAL=nvim
export DELTA_PAGER="less -c -X"

export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
for f in coreutils findutils make gnu-sed; do
  export PATH="/opt/homebrew/opt/$f/libexec/gnubin:$PATH"
done
export EDITOR="$VISUAL"
export LESSHISTFILE=$HOME/.cache/lesshst
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
export TERM=xterm-256color
export GOPATH="$HOME/.cache/go"
export GOBASE_FLAGS="-trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
export GOFLAGS="-ldflags=-linkmode=external $GOBASE_FLAGS"
source "$HOME/.config/voidedtech/git.env"

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

PS1="\$(git uncommitted --pwd 2>/dev/null)$PS1"

unset PREFERPS1 file

_local-completions() {
  local c
  c="$HOME/.local/completions"
  if [ ! -d "$c" ]; then
    mkdir -p "$c"
    lb bash > "$c/lb"
    tdiff --bash-completion > "$c/tdiff"
  fi
  for f in "$c/"*; do
    source "$f"
  done
  source "/opt/homebrew/etc/profile.d/bash_completion.sh"
}

_local-completions
source "$HOME/.bash_aliases"

echo
git uncommitted
