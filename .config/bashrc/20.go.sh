#!/usr/bin/env bash
if command -v go >/dev/null; then
  export GOTOOLCHAIN=local
  export GOPATH="$HOME/Library/Go"
  export PATH="$GOPATH/bin:$PATH"
fi
