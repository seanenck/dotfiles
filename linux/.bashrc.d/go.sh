#!/usr/bin/env bash
export GOPATH="$HOME/.cache/go"
export GOFLAGS="-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"

macos-build() {
  GOOS=darwin GOFLAGS=$(echo "$GOFLAGS" | sed 's/-buildmode=pie //g') $@
}
