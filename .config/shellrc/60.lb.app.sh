#!/usr/bin/env bash
SECRETS="$HOME/Env/secrets"
if [ -d "$SECRETS" ]; then
  export SECRET_ROOT="$SECRETS"
  LB_ENV="$SECRET_ROOT/db/lockbox.bash"
  if [ -e "$LB_ENV" ]; then
    source "$LB_ENV"
  fi
  unset LB_ENV 
fi
unset SECRETS
