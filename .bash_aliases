#!/usr/bin/env bash
if command -v bat > /dev/null; then
  alias cat=bat
fi

alias diff="diff --color -u"
alias ls='ls --color=auto'

if command -v rg > /dev/null; then
  alias grep="rg"
else
  alias grep="grep --color=auto"
fi

alias vi="$EDITOR"
alias vim="$EDITOR"
alias less="less -R"

if command -v go >/dev/null; then
  golint() {
    test ! -e go.mod && echo "cowardly refusing to run without go.mod" && return
    revive ./... | sed 's#^#revive:      #g'
    go vet ./... | sed 's#^#go vet:      #g'
    staticcheck -checks all -debug.run-quickfix-analyzers ./... | sed 's#^#staticcheck: #g'
    gofumpt -l -extra $(find . -type f -name "*.go") | sed 's#^#gofumpt:     #g'
  }
fi
