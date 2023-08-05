#!/usr/bin/env bash
_df() {
  df -h 2>/dev/null | grep "^$1" | grep "$2" | awk '{printf("%-15s%s\n", $1, $5)}' | sort -u | sed 's/^/  -> /g'
}
_disk() {
  local f filter
  echo "disk:"
  for f in share /dev/vd; do
    filter=""
    if [ "$f" == "/dev/vd" ]; then
      filter="$f[a-z][0-9]"
    fi
    _df "$f" "$filter"
  done
}

_disk
echo
git uncommitted
