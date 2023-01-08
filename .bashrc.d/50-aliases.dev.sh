#!/usr/bin/env bash
goimports() {
    gopls format $@
}

gomod-update() {
    go get -u ./...
    go mod tidy
}

