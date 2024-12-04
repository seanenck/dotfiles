#!/bin/sh
if command -v just >/dev/null; then
  for RECIPE in $(just --global-justfile --summary); do
    alias $RECIPE="just --global-justfile $RECIPE"
  done
  unset RECIPE
fi
