#!/usr/bin/env bash
echo
if ! git uncommitted --quiet; then
  echo "uncommitted:"
  git uncommitted | cut -d " " -f 1 | sort -u | sed "s#$HOME/##g" | sed 's/^/  -> /g'
  echo
fi
