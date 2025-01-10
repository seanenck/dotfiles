#!/usr/bin/env bash
[[ $- != *i* ]] && return
[[ -n "$BASHRC_INIT" ]] && return

export BASHRC_INIT=1
# system bashrc definitions
[ -s "/etc/bashrc" ] && source "/etc/bashrc"
[ -s "/etc/bash/bashrc" ] && source "/etc/bash/bashrc"
[ -s "/etc/bash.bashrc" ] && source "/etc/bash.bashrc"
[ -s "/etc/bash/bash.bashrc" ] && source "/etc/bash/bash.bashrc"
export -n BASHRC_INIT

shopt -s direxpand
shopt -s checkwinsize

# disable ctrl+s
stty -ixon

if [ -e /etc/os-release ]; then
  HOST_OS="$(grep '^ID=' /etc/os-release | cut -d "=" -f 2 | sed 's/"//g')"
  HOST_OS_VERSION="$(grep '^VERSION_ID=' /etc/os-release | cut -d "=" -f 2 | cut -d "." -f 1,2)"
  export HOST_OS HOST_OS_VERSION
  [ "$HOST_OS" = "debian" ] && touch ~/.hushlogin
fi

mkdir -p "$HOME/.local/bin" "$HOME/.local/state" "$HOME/.local/ttypty" "$HOME/.local/share/bash-completion/completions"
export PATH="$HOME/.local/bin:$PATH"

export EDITOR=vi
command -v vim >/dev/null && export EDITOR=vim
command -v nvim >/dev/null && export EDITOR=nvim
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""

export GOPATH="$HOME/.cache/go"
[ -d "$HOME/.cache/staticcheck" ] && find "$HOME/.cache/staticcheck" -type f -mtime +1 -delete 
[ -d "$HOME/.cache/gopls" ] && find "$HOME/.cache/gopls" -type f -mtime +1 -delete 
[ -d "$HOME/.local/state/nvim" ] && find "$HOME/.local/state/nvim" -type f -mtime +1 -delete

if command -v delta > /dev/null; then
  export GIT_PAGER=delta
  export DELTA_PAGER="less -R -c -X"
fi

setup-sshagent() {
  local envfile
  envfile="$HOME/.local/state/ssh-agent.env"
  if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > "$envfile"
  fi
  export SSH_AUTH_SOCK="$HOME/.local/state/ssh-agent.socket"
  if [ ! -f "$SSH_AUTH_SOCK" ]; then
    source "$envfile" > /dev/null
  fi
  ssh-add "$HOME/.ssh/"*.privkey >/dev/null 2>&1
}

setup-sshagent
unset -f setup-sshagent

export SECRET_ROOT="$HOME/.local/ttypty/secrets"
[ -s "$SECRET_ROOT/secrets.env" ] && source "$SECRET_ROOT/secrets.env" && export SECRETS_ENV_FILE="$SECRET_ROOT/secrets.env"
export CFG_LB="linux"
[ -n "$SSH_CONNECTION" ] && export CFG_LB="linux.ssh" 

source "$HOME/.bash_aliases"

command -v dotfiles >/dev/null && dotfiles --check
command -v git-motd >/dev/null && git motd

PS1="[\u@\[\e[93m\]\h\[\e[0m\]:\W]$ "
command -v git-uncommitted >/dev/null && PS1="\$(git uncommitted pwd 2>/dev/null)$PS1"
