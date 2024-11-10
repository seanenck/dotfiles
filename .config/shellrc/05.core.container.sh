#!/bin/sh
FILE="/run/.containerenv"
if [ -e "$FILE" ]; then
  export CONTAINER_NAME="$(grep "name=" "$FILE" | sed 's/"//g' | cut -d "=" -f 2)"
else
  if [ -n "$CONTAINER_ID" ]; then
    export CONTAINER_NAME="$CONTAINER_ID"
  fi
fi
unset FILE
