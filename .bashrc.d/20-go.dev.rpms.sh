#!/usr/bin/env bash
export GOPATH="$HOME/.cache/go"
export GOFLAGS="-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
