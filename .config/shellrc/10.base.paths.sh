#!/bin/sh
DIR="$HOME/.bash"
if [ -d "$DIR" ]; then
  PATHS="$DIR/paths"
  if [ -d "$PATHS" ]; then
    for FILE in "$PATHS/"*; do
      BASE=$(cat "$FILE")
      export PATH="$BASE:$PATH"
    done
  fi
  PATHS="$DIR/completions"
  if [ -d "$PATHS" ]; then
    for FILE in "$PATHS/"*; do
      source "$FILE"
    done
  fi
  unset FILE BASE PATHS
fi
unset DIR
