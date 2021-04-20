#!/bin/bash
brew() {
    local has bin
    bin=/opt/homebrew/bin/brew
    has=0
    if [ ! -z "$1" ]; then
        has=1
        if [[ "$1" == "cupgrade" ]]; then
            echo "updating casks"
            $bin upgrade $(brew outdated --cask --greedy --quiet)
            return
        fi
    fi
    $bin $@
    if [ $has -eq 1 ]; then
        if [[ "$1" == "install" ]] || [[ "$1" == "remove" ]]; then
            cfg=~/.config/voidedtech
            rm -f $cfg/Brewfile
            cwd=$PWD
            cd $cfg && $bin bundle dump
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
