#!/bin/sh
SECRETS="$HOME/Env/secrets"
if [ -d "$SECRETS" ]; then
  for DIR in "secrets" "wac"; do
    DIR_ENV="$HOME/Env/$DIR/$DIR.env"
    if [ -e "$DIR_ENV" ]; then
      source "$DIR_ENV"
      export "$(echo "${DIR}" | tr '[:lower:]' '[:upper:]')_ENV_FILE"="$DIR_ENV"
    fi
  done
  CONFIG_TOML="$(uname | tr '[:upper:]' '[:lower:]')"
  if [ -n "$SSH_CONNECTION" ]; then
    CONFIG_TOML="$CONFIG_TOML.ssh"
  fi
  export CFG_LB="$CONFIG_TOML"
  unset DIR_ENV CONFIG_TOML DIR
fi
unset SECRETS
