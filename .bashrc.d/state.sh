#!/usr/bin/env bash
echo "state"
echo "==="
echo
df -h / | tail -n +2 | awk '{print "disk usage: " $5}'
echo
if ! git uncommitted --quiet; then
  echo "uncommitted:"
  git uncommitted | cut -d " " -f 1 | sort -u | sed "s#$HOME/##g" | sed 's/^/  -> /g'
  echo
fi
touch "$HOME/.cache/login"
