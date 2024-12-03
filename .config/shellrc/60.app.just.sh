#!/bin/sh
if command -v just >/dev/null; then
  for RECIPE in $(just --justfile "$HOME/.justfile" --summary); do
    alias $RECIPE="just --justfile "$HOME/.justfile" $RECIPE"
  done
  unset RECIPE
fi
