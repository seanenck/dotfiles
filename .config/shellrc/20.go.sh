#!/usr/bin/env bash
HAS_GO=0
if command -v go >/dev/null; then
  export GOTOOLCHAIN=local
  HAS_GO=1
fi
for DIR in "Library" ".cache"; do
  DIR="$HOME/$DIR"
  if [ -d "$DIR" ]; then
    GOPATH="$DIR/go"
    if [ "$HAS_GO" -eq 1 ]; then
      export GOPATH
    fi
    export PATH="$GOPATH/bin:$PATH"
  fi
done
unset DIR HAS_GO
