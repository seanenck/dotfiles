#!/usr/bin/env bash
if command -v manage-data > /dev/null; then
  if [ -z "$SSH_CONNECTION" ]; then
    (manage-data tasks &)
  fi
fi
