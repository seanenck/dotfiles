#!/bin/sh
PATHS="$HOME/.bash/paths"
if [ -d "$PATHS" ]; then
  for FILE in "$PATHS/"*; do
    LOCATION=$(cat "$FILE")
    export PATH="$LOCATION:$PATH"
  done
fi
