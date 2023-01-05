#!/usr/bin/env bash
alias cat=bat
alias diff="diff -u"
alias ls='ls --color=auto'
alias grep="rg"
alias vi=$EDITOR
alias vim=$EDITOR
alias hx=$EDITOR

if [ -n "$TOOLBOX" ] && [ "$TOOLBOX" == "go" ]; then
  goimports() {
      gopls format $@
  }

  gomod-update() {
      go get -u ./...
      go mod tidy
  }
fi