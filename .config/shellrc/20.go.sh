#!/usr/bin/env bash
if command -v go >/dev/null; then
  for DIR in "Library" ".cache"; do
    DIR="$HOME/$DIR"
    if [ -d "$DIR" ]; then
      export GOPATH="$DIR/go"
      export PATH="$GOPATH/bin:$PATH"
    fi
  done
  unset DIR
fi
