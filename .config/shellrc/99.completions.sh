#!/bin/sh
COMPS="$HOME/.config/shellrc/completions"
if [ -d "$COMPS" ]; then
  for FILE in lb blap; do
    if ! command -v "$FILE" > /dev/null; then
      continue
    fi
    BASE="$COMPS/$FILE"
    if [ -e "$BASE" ]; then
      continue
    fi
    $FILE completions > "$BASE"
  done
  for FILE in "$COMPS/"*; do
    BASE=$(basename "$FILE")
    if command -v "$BASE" > /dev/null; then
      source "$FILE"
    fi
  done
  unset FILE BASE
fi
unset COMPS
