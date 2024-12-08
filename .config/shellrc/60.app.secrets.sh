#!/bin/sh
SECRETS="$HOME/Env/secrets"
if [ -d "$SECRETS" ]; then
  export SECRET_ROOT="$SECRETS"
  SECRET_ENV="$SECRET_ROOT/secrets.env"
  if [ -e "$SECRET_ENV" ]; then
    source "$SECRET_ENV"
  fi
  CONFIG_TOML="$(uname | tr '[:upper:]' '[:lower:]')"
  if [ -n "$SSH_CONNECTION" ]; then
    CONFIG_TOML="$CONFIG_TOML.ssh"
  fi
  export CFG_LB="$CONFIG_TOML"
  unset SECRET_ENV CONFIG_TOML
fi
unset SECRETS
