#!/bin/sh
CARGO="$HOME/.cargo/"
DIR="${CARGO}bin"
if [ -e "$DIR" ]; then
  export PATH="$DIR:$PATH"
fi
FILE="${CARGO}env"
if [ -e "$FILE" ]; then
  source "$FILE"
fi
unset DIR FILE
