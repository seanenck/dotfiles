#!/usr/bin/env bash
if command -v ssh-agent > /dev/null; then
  LOCAL_STATE="$HOME/.local/state"
  SSH_FILES="$HOME/.ssh"
  if [ -e "$SSH_FILES/allowed_signers" ]; then
    SSH_AGENT_ENV="$LOCAL_STATE/ssh-agent.env"
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
      ssh-agent > "$SSH_AGENT_ENV"
    fi
    export SSH_AUTH_SOCK="$LOCAL_STATE/ssh-agent.socket"
    if [ ! -f "$SSH_AUTH_SOCK" ]; then
      source "$SSH_AGENT_ENV" > /dev/null
    fi
    for FILE in "$SSH_FILES/"*.privkey; do
      ssh-add "$FILE" > /dev/null 2>&1
    done
  fi
  
  unset LOCAL_STATE SSH_AGENT_ENV FILE SSH_FILES
fi
