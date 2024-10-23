#!/usr/bin/env bash
DIR="$HOME/.local/bin"
if [ -d "$DIR" ]; then
  export PATH="$DIR:$PATH"
  if [ -n "$CONTAINER_NAME" ]; then
    DIR="$DIR/$CONTAINER_NAME"
  else
    DIR="$DIR/host"
  fi
  if [ -d "$DIR" ]; then
    PATH="$DIR:$PATH"
  fi
fi

DIR="/opt/fs/root"
if [ -d "$DIR" ]; then
  export PATH="$DIR/bin:$PATH";
  export MANPATH="$DIR/share/man${MANPATH+:$MANPATH}:";
fi

unset DIR
