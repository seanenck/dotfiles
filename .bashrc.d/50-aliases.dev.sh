#!/usr/bin/env bash
gomod-update() {
  go get -u ./...
  go mod tidy
}
