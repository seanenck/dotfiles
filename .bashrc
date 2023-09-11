#!/usr/bin/env bash
[[ $- != *i* ]] && return

source /etc/bashrc

shopt -s direxpand

export VISUAL=vi
export VISUAL=nvim
export DELTA_PAGER="less -c -X"

export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
for f in coreutils findutils make gnu-sed; do
  export PATH="/opt/homebrew/opt/$f/libexec/gnubin:$PATH"
done
export EDITOR="$VISUAL"
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
export GOPATH="$HOME/Library/Caches/go"
export GOFLAGS="-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
export HOME_GIT="$HOME/.local/git"
export GIT_UNCOMMIT="$HOME_GIT $HOME/workspace"

# disable ctrl+s
stty -ixon

# check the window size after each command
shopt -s checkwinsize

PREFERPS1="(\u@\h \W)"
PS1=$PREFERPS1'$ '
SSH_AGENT_ENV="$HOME/.local/state/ssh-agent.env"
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > "$SSH_AGENT_ENV"
fi
export SSH_AUTH_SOCK="$HOME/.local/state/ssh-agent.socket"
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$SSH_AGENT_ENV" >/dev/null
fi
for file in "$HOME/.ssh/"*.key; do
  ssh-add "$file" > /dev/null 2>&1
done

PS1="\$(git uncommitted --pwd 2>/dev/null)$PS1"

unset PREFERPS1 file

_local-completions() {
  local c f
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
