#!/usr/bin/env bash
_df() {
  df -h 2>/dev/null | grep "^$1" | grep "$2" | awk '{printf("%-15s%s\n", $1, $5)}' | sort -u | sed 's/^/  -> /g'
}
_disk() {
  echo "disk:"
  _df "workspace" "" | sed "s/share/host /g"
  _df "/dev/vd" "/dev/vd[a-z][0-9]"
}

_disk
echo
