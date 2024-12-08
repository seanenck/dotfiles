#!/bin/sh
for DIR in "Library" ".cache"; do
  DIR="$HOME/$DIR"
  if [ -d "$DIR" ]; then
    export GOPATH="$DIR/go"
    for MODULE in gopls staticcheck; do
      SUB="$DIR/$MODULE"
      if [ -d "$SUB" ]; then
        find "$SUB" -type f -mtime +1 -delete
      fi
    done
  fi
done
unset DIR
