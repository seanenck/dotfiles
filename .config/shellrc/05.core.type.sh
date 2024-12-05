#!/bin/sh
if [ "$(uname)" = "Linux" ]; then
  export HOST_OS="$(grep '^ID=' /etc/os-release | cut -d "=" -f 2 | sed 's/"//g')"
  export HOST_OS_VERSION="$(grep '^VERSION_ID=' /etc/os-release | cut -d "=" -f 2 | cut -d "." -f 1,2)"
  FILE="/run/.containerenv"
  if [ -e "$FILE" ]; then
    export CONTAINER_NAME="$(grep "name=" "$FILE" | sed 's/"//g' | cut -d "=" -f 2)"
  else
    if [ -n "$CONTAINER_ID" ]; then
      export CONTAINER_NAME="$CONTAINER_ID"
    fi
  fi
  unset FILE
fi
