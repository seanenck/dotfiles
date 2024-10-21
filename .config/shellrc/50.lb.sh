#!/usr/bin/env bash
if command -v lb > /dev/null; then
  export SECRET_ROOT="$HOME/Env/secrets"
  LB_ENV="$SECRET_ROOT/db/lockbox.bash"
  if [ -e "$LB_ENV" ]; then
    source "$LB_ENV"
  fi
  unset LB_ENV 
fi
