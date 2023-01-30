#!/usr/bin/env bash
[[ $- != *i* ]] && return

. /etc/bashrc

HISTCONTROL=ignoreboth:erasedups

shopt -s histappend
shopt -s direxpand

HISTSIZE=-1
HISTFILESIZE=-1

export VISUAL=nvim
export EDITOR="$VISUAL"
export LESSHISTFILE=$HOME/.cache/lesshst
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
export TERM=xterm-256color
export DELTA_PAGER="less -c -X"
export PATH="$HOME/.bin/:$PATH"
export LOCAL_STORE="$HOME/.store"
export PKGS_STORE="$LOCAL_STORE/pkgs"
export RPMS_STORE="$PKGS_STORE/rpms"

# disable ctrl+s
stty -ixon

# check the window size after each command
shopt -s checkwinsize

export SSH_AGENT_ENV="$XDG_RUNTIME_DIR/ssh-agent.env"
if [ ! -e "$SSH_AGENT_ENV" ] || ! pgrep ssh-agent > /dev/null; then
  pkill ssh-agent
  ssh-agent > "$SSH_AGENT_ENV"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
  source "$SSH_AGENT_ENV" >/dev/null
fi
for file in $(find "$HOME/.ssh/" -type f -name "*.key"); do
  ssh-add "$file" > /dev/null 2>&1
done

_toolbox-name(){
  local name
  if [ -f "/run/.toolboxenv" ]; then
    name=$(grep -oP "(?<=name=\")[^\";]+" /run/.containerenv)
    echo "$name"
  fi
}

_toolbox-prompt() {
  local name
  name=$(_toolbox-name)
  if [ -n "$name" ]; then
    echo "[$name]"
  fi
}

PREFERPS1="(\u@\h \W)"
TOOLBOX=$(_toolbox-name)
if [ -n "$TOOLBOX" ]; then
  export TOOLBOX=$TOOLBOX
  HOME_BASH="$TOOLBOX"
  PS1='\[\033[01;33m\]'$PREFERPS1'\[\033[0m\]> '
else
  unset TOOLBOX
  PS1=$PREFERPS1'$ '
  HOME_BASH="host"
fi
export PATH="$HOME/.bin/$HOME_BASH:$PATH"
PS1="\$(_toolbox-prompt)\$(git-uncommitted --pwd 2>/dev/null)$PS1"

for file in $(find "$HOME/.bashrc.d" -name "*.sh" | grep -E "($HOME_BASH|all).sh\$" | sort); do
  # shellcheck source=/dev/null
  source "$file"
done
unset HOME_BASH PREFERPS1 file
