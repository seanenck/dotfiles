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
export PATH="$HOME/.local/bin/:$PATH"
export GOPATH="$HOME/.cache/go"
export GOBASE_FLAGS="-trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
export GOFLAGS="-ldflags=-linkmode=external $GOBASE_FLAGS"

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

for file in "$HOME/.local/completions/"*.sh; do
  if [ -e "$file" ]; then
    source "$file"
  fi
done
unset PREFERPS1 file

if [ -x /usr/bin/bat ];then
  alias cat=bat
fi
alias diff="diff --color -u"
alias ls='ls --color=auto'
if [ -x /usr/bin/rg ]; then
  alias grep="rg"
fi
alias vi="$EDITOR"
alias vim="$EDITOR"
alias scp="echo noop"
alias abw-sync="abw sync"

# state
_df() {
  df -h 2>/dev/null | grep "^$1" | grep "$2" | awk '{printf("%-15s%s\n", $1, $5)}' | sort -u | sed 's/^/  -> /g'
}
_disk() {
  echo "disk:"
  _df "workspace" "" | sed "s/share/host /g"
  _df "/dev/vd" "/dev/vd[a-z][0-9]"
  _df "tmpfs" "/home"
}

_disk
echo
git uncommitted
