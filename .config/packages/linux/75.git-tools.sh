#!/bin/sh -e
unpack() {
  extract_source_tar "$1" "git-tools"
  dir=$(app_dir "git-tools")
  (cd "$dir" && just --quiet)
  for file in git-uncommitted git-motd git-current-state; do
    (cd "$dir" && install -Dm755 "$PWD/target/$file" "$PKGS_BIN/$file")
  done
}

source_tar "github" "seanenck/git-tools"
