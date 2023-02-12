#!/usr/bin/env bash
declare -a PACKAGES=( \
  "bat" \
  "efmlsp" \
  "git" \
  "git-delta" \
  "glibc-langpack-en" \
  "neovim" \
  "netcat" \
  "ripgrep" \
  "rsync" \
  "shellcheck" \
)

declare -a RPMS=( \
  "make" \
  "mock" \
  "rpmlint" \
  "rpmdevtools" \
)

declare -a DEV=( \
  "file" \
  "go" \
  "gofumpt" \
  "gopls" \
  "make" \
  "staticcheck" \
  "revive" \
)

declare -a CARGO=( \
  "cargo" \
  "rust" \
  "rust-analyzer" \
  "rustfmt" \
)

declare -A BOXES=( \
  ["rpms"]="${RPMS[@]}" \
  ["dev"]="${DEV[@]}" \
  ["cargo"]="${CARGO[@]}" \
)

export BOXES
export PACKAGES
