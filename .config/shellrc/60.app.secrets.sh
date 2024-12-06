#!/bin/sh
SECRETS="$HOME/Env/secrets"
if [ -d "$SECRETS" ]; then
  export SECRET_ROOT="$SECRETS"
  SECRET_ENV="$SECRET_ROOT/secrets.env"
  if [ -e "$SECRET_ENV" ]; then
    source "$SECRET_ENV"
  fi
  CONFIG_TOML="$SECRET_ROOT/configs/$(uname | tr '[:upper:]' '[:lower:]')"
  if [ -n "$SSH_CONNECTION" ]; then
    CONFIG_TOML="$CONFIG_TOML.ssh"
  fi
  CONFIG_TOML="$CONFIG_TOML.toml"
  if [ -e "$CONFIG_TOML" ]; then
    export LOCKBOX_CONFIG_TOML="$CONFIG_TOML"
  fi
  unset SECRET_ENV CONFIG_TOML
fi
unset SECRETS
