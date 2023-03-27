#!/usr/bin/env bash
if ! git uncommitted --quiet; then
  echo
  echo "uncommitted:"
  git uncommitted | cut -d " " -f 1 | sort -u | sed "s#$HOME/##g" | sed 's/^/  -> /g'
  echo
fi

_backups() {
  systemctl --user set-environment LOCAL_STORE="$LOCAL_STORE"
  systemctl start --user backups
  if data-sync --check; then
    return
  fi
  echo
  echo "backups:"
  echo "  -> backup issues"
  echo
}

_backups
system-ostree check
