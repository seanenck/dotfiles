#!/bin/sh
DIR="$HOME/.shell"
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
    SH=$(basename "$SHELL")
    for FILE in "$PATHS/"*.$SH; do
      source "$FILE"
    done
  fi
  unset FILE BASE PATHS SH
fi
unset DIR
