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

export EDITOR=vim
export VISUAL=vim
export DELTA_PAGER="less -c -X"
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
source "$HOME/.bash_aliases"

if [ -d "/opt/homebrew" ]; then
  export HOMEBREW_PREFIX="/opt/homebrew";
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
  export HOMEBREW_REPOSITORY="/opt/homebrew";
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
  export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
fi

if command -v go >/dev/null; then
  export GOPATH="$HOME/Library/Go"
  export PATH="$GOPATH/bin:$PATH"
fi

export PATH="$HOME/.local/bin:$PATH"

# disable ctrl+s
stty -ixon

LOCAL_STATE="$HOME/.local/state"
mkdir -p "$LOCAL_STATE"

if command -v lb > /dev/null; then
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

PS1="[\u@\[\e[93m\]\h\[\e[0m\]:\W]$ "
PS1="\$(git uncommitted --mode pwd 2>/dev/null)$PS1"

unset LOCAL_STATE SSH_AGENT_ENV FILE PS1_COLOR

if command -v manage-data > /dev/null; then
  manage-data tasks
fi

git-uncommitted --mode motd
