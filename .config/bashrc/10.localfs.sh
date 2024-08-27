#!/usr/bin/env bash
DIR="$HOME/.local/bin"
if [ -d "$DIR" ]; then
  export PATH="$DIR:$PATH"
fi
DIR="/opt/fs/root"
if [ -d "$DIR" ]; then
  export PATH="$DIR/bin:$PATH";
  export MANPATH="$DIR/share/man${MANPATH+:$MANPATH}:";
fi

unset DIR
