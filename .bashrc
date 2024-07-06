#!/usr/bin/env bash
[[ $- != *i* ]] && return

for FILE in /etc/bashrc /etc/bash.bashrc /etc/bash/bashrc /etc/bash/bash.bashrc /opt/homebrew/etc/profile.d/bash_completion.sh; do
  if [ -s "$file" ]; then
    source "$file"
  fi
done

shopt -s direxpand
# check the window size after each command
shopt -s checkwinsize

export EDITOR=nvim
export VISUAL=nvim
export DELTA_PAGER="less -c -X"
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""

if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

source "$HOME/.bash_aliases"

# disable ctrl+s
stty -ixon

LOCAL_STATE="$HOME/.local/state"
mkdir -p "$LOCAL_STATE"
if [ -d "$LOCAL_STATE/nvim/undo" ]; then
  find "$LOCAL_STATE/nvim/undo" -type f -mmin +60 -delete
fi

if command -v go; then
  export GOPATH="$HOME/.cache/go"
  export PATH="$GOPATH/bin:$PATH"
  export GOFLAGS="-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
fi

export ENABLE_LSP=1

export SECRET_ROOT="$HOME/Env/secrets"
LB_ENV="$SECRET_ROOT/db/lockbox.bash"
if [ -e "$LB_ENV" ]; then
  source "$LB_ENV"
fi
unset LB_ENV 

SSH_AGENT_ENV="$LOCAL_STATE/ssh-agent.env"
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  ssh-agent > "$SSH_AGENT_ENV"
fi
export SSH_AUTH_SOCK="$LOCAL_STATE/ssh-agent.socket"
if [ ! -f "$SSH_AUTH_SOCK" ]; then
  source "$SSH_AGENT_ENV" > /dev/null
fi
for FILE in "$HOME/.ssh/"*.privkey; do
  ssh-add "$FILE" > /dev/null 2>&1
done

for FILE in "$HOME/.completions/"*.bash; do
  source "$FILE"
done
unset LOCAL_STATE SSH_AGENT_ENV FILE

PS1="[\u@\h:\W]$ "
PS1="\$(git uncommitted --pwd 2>/dev/null)$PS1"

caffeinate task-runner
git-uncommitted --motd
