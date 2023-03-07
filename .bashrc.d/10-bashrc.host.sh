#!/usr/bin/env bash
if ! git uncommitted --quiet; then
  echo
  echo "uncommitted:"
  git uncommitted | cut -d " " -f 1 | sort -u | sed "s#$HOME/##g" | sed 's/^/  -> /g'
  echo
fi

if ! upstreams --check; then
  echo
  echo "upstreams:"
  echo "  -> check for updates"
  echo
fi

_backups() {
  local data
  data=$(data-backups --check)
  if [ -z "$data" ]; then
    return
  fi
  echo
  echo "backups:"
  echo "$data" | sed 's/^/  -> /g'
  echo
}

_backups
data-backups --daily
system-ostree check
