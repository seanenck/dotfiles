#!/usr/bin/env bash
_disk() {
  local f
  echo "disk:"
  for f in share /dev/vd; do
    df -h 2>/dev/null | grep "^$f" | awk '{printf("%-15s%s\n", $1, $5)}' | sort -u | sed 's/^/  -> /g'
  done
}

_disk
echo
if ! git uncommitted --quiet; then
  echo "uncommitted:"
  git uncommitted | cut -d " " -f 1 | sort -u | sed "s#$HOME/##g" | sed 's/^/  -> /g'
  echo
fi
