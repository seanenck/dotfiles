#!/bin/sh
FILE="$HOME/.cargo/env"
if [ -e "$FILE" ]; then
  source "$FILE"
fi
unset FILE
