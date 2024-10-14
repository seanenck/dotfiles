#!/bin/sh
if ! command -v delta > /dev/null; then
  for FILE in /usr/bin/git*; do
    alias $(basename "$FILE")=""
  done
fi
