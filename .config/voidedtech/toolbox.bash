#!/usr/bin/env bash
declare -a PACKAGES=( \
  "bat" \
  "git" \
  "git-delta" \
  "git-gui" \
  "glibc-langpack-en" \
  "jq" \
  "neovim" \
  "netcat" \
  "ripgrep" \
  "rsync" \
  "shellcheck" \
  "efmlsp" \
)

declare -a DEV=( \
  "file" \
  "go" \
  "make" \
  "gofumpt" \
  "gopls" \
  "revive" \
  "staticcheck" \
)

declare -a RPMS=( \
  "make" \
  "mock" \
  "rpmlint" \
  "rpmdevtools" \
)

declare -a CARGO=( \
  "cargo" \
  "rust" \
  "rust-analyzer" \
  "rustfmt" \
  "clippy" \
)

declare -A BOXES=( \
  ["dev"]="${DEV[@]}" \
  ["cargo"]="${CARGO[@]}" \
  ["rpms"]="${RPMS[@]}" \
)

export BOXES
export PACKAGES
