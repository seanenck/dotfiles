#!/usr/bin/env bash
goupdate() {
  go get -u ./...
  go mod tidy
}

_glint() {
  revive ./... 2>&1 | sed "s/^/[revive]      -> /g"
  gofumpt -l -extra $(find . -type f -name "*.go") 2>&1 | sed "s/^/[gofumpt]    -> /g"
  staticcheck -checks all -debug.run-quickfix-analyzers ./... 2>&1 | sed "s/^/[staticcheck] -> /g"
  go vet ./... 2>&1 | sed "s/^/[govet]       -> /g"
}

glint() {
  if [ -d "vendor" ] ; then
    _glint | grep -v "vendor/"
  else
    _glint
  fi
}

alias cat=bat
alias diff="diff --color -u"
alias ls='ls --color=auto'
alias grep="rg"
alias vi="$EDITOR"
alias vim="$EDITOR"
alias scp="echo noop"
alias utmctl="/Applications/UTM.app/Contents/MacOS/utmctl"
