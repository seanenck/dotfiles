#!/bin/sh
FILE="/run/.containerenv"
if [ -e "$FILE" ]; then
  NAME=$(grep "name=" "$FILE" | sed 's/"//g' | cut -d "=" -f 2)
  export CONTAINER_NAME="$NAME"
  FILE="$HOME/.local/bin/$NAME"
else
  FILE="$HOME/.local/bin/host"
fi
if [ -d "$FILE" ]; then
  PATH="$FILE:$PATH"
fi
unset FILE
