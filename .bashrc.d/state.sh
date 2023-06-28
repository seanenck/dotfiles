#!/usr/bin/env bash
echo "state"
echo "==="
df -h / | tail -n +2 | awk '{print "disk usage: " $5}'
if ! git uncommitted --quiet; then
  echo
  echo "uncommitted:"
  git uncommitted | cut -d " " -f 1 | sort -u | sed "s#$HOME/##g" | sed 's/^/  -> /g'
  echo
fi
