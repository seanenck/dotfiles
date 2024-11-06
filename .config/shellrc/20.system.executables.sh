#!/bin/sh
FILE="$HOME/.local/state/system/executables"
if [ -e "$FILE" ]; then
  FIRST=1
  for EXE in $(cat "$FILE"); do
    if ! command -v "$EXE" > /dev/null; then
      if [ "$FIRST" -eq 1 ]; then
        echo "[executables]"
        echo "==="
        FIRST=0
      fi
      echo "-> $EXE (missing)"
    fi
  done
  if [ "$FIRST" -ne 1 ]; then
    echo
  fi
  unset FIRST EXE
fi
unset FILE
