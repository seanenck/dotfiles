#!/bin/sh
COMPS="$HOME/.config/shellrc/completions"
if [ -d "$COMPS" ]; then
  for FILE in "$COMPS/"*; do
    BASE=$(basename "$FILE")
    if command -v "$BASE" > /dev/null; then
      source "$FILE"
    fi
  done
fi
