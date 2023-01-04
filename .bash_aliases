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

new-toolbox() {
  if [ -z "$1" ]; then
    echo "requires a name"
    return
  fi
  if ! toolbox create "$1"; then
    echo "failed to create $1"
    return
  fi
  if ! toolbox run --container "$1" sudo dnf install -y ripgrep bat git-delta git netcat; then
    echo "failed to install default packages"
    return
  fi
  toolbox enter $1
}
