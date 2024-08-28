#!/usr/bin/env bash
if command -v manage-data > /dev/null; then
  (manage-data tasks &)
fi
