#!/usr/bin/env bash
export GOPATH="$HOME/.cache/go"
export GOFLAGS="-trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
