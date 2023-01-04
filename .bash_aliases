#!/usr/bin/env bash
alias cat=bat

goimports() {
    gopls format $@
}

gomod-update() {
    go get -u ./...
    go mod tidy
}

new-toolbox() {
  if [ -z "$1" ]; then
    echo "requires a name"
    return
  fi
  if ! toolbox create "$1"; then
    echo "failed to create $1"
    return
  fi
  if ! toolbox run --container "$1" sudo dnf install -y bat git-delta git; then
    echo "failed to install default packages"
    return
  fi
  toolbox enter $1
}
