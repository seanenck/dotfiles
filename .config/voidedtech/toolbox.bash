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

declare -a DEV=( \
  "file" \
  "go" \
  "make" \
)

declare -a CARGO=( \
  "cargo" \
  "rust" \
  "rust-analyzer" \
  "rustfmt" \
)

declare -A BOXES=( \
  ["dev"]="${DEV[@]}" \
  ["cargo"]="${CARGO[@]}" \
)

export BOXES
export PACKAGES
