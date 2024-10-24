#!/usr/bin/env bash
for DIR in "Library" ".cache"; do
  DIR="$HOME/$DIR"
  if [ -d "$DIR" ]; then
    export GOPATH="$DIR/go"
  fi
done
unset DIR
if command -v go >/dev/null; then
  golint() {
    if [ ! -e go.mod ]; then
      echo "cowardly refusing to run outside go.mod root"
      return
    fi
    revive ./... | sed 's#^#revive:      #g'
    go vet ./... | sed 's#^#go vet:      #g'
    staticcheck -checks all -debug.run-quickfix-analyzers ./... | sed 's#^#staticcheck: #g'
    gofumpt -l -extra $(find . -type f -name "*.go") | sed 's#^#gofumpt:     #g'
  }
fi
