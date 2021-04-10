#!/bin/bash
brew() {
    /opt/homebrew/bin/brew $@
    if [ ! -z "$1" ]; then
        if [[ "$1" == "install" ]] || [[ "$1" == "remove" ]]; then
        cfg=~/.config/voidedtech
        rm -f $cfg/Brewfile
        cwd=$PWD
        cd $cfg && /opt/homebrew/bin/brew bundle dump
        cd $cwd
        fi
    fi
}

glint() {
    local f
    goimports -l . | grep -v bindata.go | sed 's/^/[goimports]    /g'
    revive ./... | sed 's/^/[revive]       /g'
    for f in $(find . -type f -name "*.go" -exec dirname {} \; | sort -u); do
        go vet $f | sed 's/^/[govet]        /g'
    done
    golangci-lint run
}
