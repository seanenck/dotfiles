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

[ -e /etc/os-release ] && grep -q '^ID=debian' /etc/os-release && touch ~/.hushlogin

mkdir -p "$HOME/.local/bin" "$HOME/.local/state" "$HOME/.local/ttypty"
export PATH="$HOME/.local/bin:$PATH"

export EDITOR=nvim
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""

export GOPATH="$HOME/.cache/go"
cleanup-caches() {
  local dir
  for dir in ".cache/staticcheck" ".cache/gopls" ".cache/go-build" ".local/state/nvim"; do
    dir="$HOME/$dir"
    [ -d "$dir" ] && find "$dir" -type f -mtime +1 -delete
  done
}

cleanup-caches
unset -f cleanup-caches

if command -v delta > /dev/null; then
  export GIT_PAGER=delta
  export DELTA_PAGER="less -R -c -X"
fi
command -v bat > /dev/null && export BAT_OPTS="-pp --theme 'Monokai Extended'"

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

CFG_LB="linux"
[ -n "$SSH_CONNECTION" ] && CFG_LB="linux.ssh" 
command -v lb > /dev/null && export LOCKBOX_CONFIG_TOML="$SECRET_ROOT/configs/$CFG_LB.toml"
unset CFG_LB

source "$HOME/.bash_aliases"

command -v dotfiles >/dev/null && dotfiles --check
command -v git-motd >/dev/null && git motd

PS1="[\u@\[\e[93m\]\h\[\e[0m\]:\W]$ "
command -v git-uncommitted >/dev/null && PS1="\$(git uncommitted pwd 2>/dev/null)$PS1"
