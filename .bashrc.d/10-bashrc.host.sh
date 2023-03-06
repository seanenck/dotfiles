#!/usr/bin/env bash
if [ -n "$SSH_CONNECTION" ]; then
  export LOCKBOX_CLIP_OSC52=yes
fi

if ! git uncommitted --quiet; then
  echo
  echo "uncommitted:"
  git uncommitted | cut -d " " -f 1 | sort -u | sed "s#$HOME/##g" | sed 's/^/  -> /g'
  echo
fi

if ! upstreams check; then
  echo
  echo "upstreams:"
  echo "  -> check for updates"
  echo
fi
(data-backups &)
system-ostree check
