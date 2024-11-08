#!/usr/bin/env bash
SECRETS="$HOME/Env/secrets"
if [ -d "$SECRETS" ]; then
  export SECRET_ROOT="$SECRETS"
  SECRET_ENV="$SECRET_ROOT/secrets.env"
  if [ -e "$SECRET_ENV" ]; then
    source "$SECRET_ENV"
  fi
  unset SECRET_ENV 
fi
unset SECRETS
