#!/bin/sh
COMPS="$HOME/.bash/completions"
if [ -d "$COMPS" ]; then
  for FILE in "$COMPS/"*; do
    BASE=$(basename "$FILE" | cut -d "." -f 1)
    if command -v "$BASE" > /dev/null; then
      source "$FILE"
    fi
  done
  unset FILE BASE
fi
unset COMPS
