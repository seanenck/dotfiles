#!/usr/bin/env bash
[[ $- != *i* ]] && return

for FILE in /etc/bashrc /etc/bash.bashrc /etc/bash/bashrc /etc/bash/bash.bashrc /opt/homebrew/etc/profile.d/bash_completion.sh; do
  if [ -s "$FILE" ]; then
    source "$FILE"
  fi
done

shopt -s direxpand
# check the window size after each command
shopt -s checkwinsize

export EDITOR=nvim
export VISUAL=nvim
export DELTA_PAGER="less -c -X"
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
export SYSTEM_PROFILE="host"
PS1_COLOR="93"
if [ -e "/run/.containerenv" ]; then
  PS1_COLOR=95
  export SYSTEM_PROFILE=dev
  export GOPATH="$HOME/.cache/go"
  export PATH="$GOPATH/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$HOME/.local/bin/$SYSTEM_PROFILE:$PATH"
fi

source "$HOME/.bash_aliases"

# disable ctrl+s
stty -ixon

LOCAL_STATE="$HOME/.local/state"
mkdir -p "$LOCAL_STATE"
if [ -d "$LOCAL_STATE/nvim/undo" ]; then
  find "$LOCAL_STATE/nvim/undo" -type f -mmin +60 -delete
fi

export ENABLE_LSP=1

if [ "$SYSTEM_PROFILE" == "host" ]; then
  export SECRET_ROOT="$HOME/Env/secrets"
  LB_ENV="$SECRET_ROOT/db/lockbox.bash"
  if [ -e "$LB_ENV" ]; then
    source "$LB_ENV"
  fi
  unset LB_ENV 

  for FILE in "$HOME/.completions/"*.bash; do
    source "$FILE"
  done
fi
  
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

PS1="[\u@\[\e[${PS1_COLOR}m\]\h\[\e[0m\]:\W]$ "
PS1="\$(git uncommitted --pwd 2>/dev/null)$PS1"

unset LOCAL_STATE SSH_AGENT_ENV FILE PS1_COLOR

if [ "$SYSTEM_PROFILE" == "host" ]; then
  systemd-inhibit task-runner
fi

git-uncommitted --motd
