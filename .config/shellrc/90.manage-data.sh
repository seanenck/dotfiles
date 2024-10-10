#!/usr/bin/env bash
if command -v manage-data > /dev/null; then
  (manage-data tasks &)
  manage-data errors
fi
