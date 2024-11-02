#!/usr/bin/env bash
for DIR in "Library" ".cache"; do
  DIR="$HOME/$DIR"
  if [ -d "$DIR" ]; then
    export GOPATH="$DIR/go"
  fi
done
unset DIR
