#!/bin/sh
for RECIPE in $(just --global-justfile --summary); do
  alias $RECIPE="just --global-justfile $RECIPE"
done
unset RECIPE
