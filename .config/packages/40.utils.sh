#!/bin/sh -e
[ "$PKGS_UNAME" != "Linux" ] && return

unpack() {
  extract_source_tar "$1" "git-tools"
  dir=$(app_dir "git-tools")
  (cd "$dir" && just --quiet)
  for file in git-uncommitted git-motd git-current-state; do
    (cd "$dir" && install -Dm755 "$PWD/target/$file" "$PKGS_BIN/$file")
  done
}

source_tar "seanenck/git-tools"

unpack() {
  extract_source_tar "$1" "lb"
  dir=$(app_dir "lb")
  (cd "$dir" && just --quiet version="$PKGS_TAG")
  (cd "$dir" && install -Dm755 "$PWD/target/lb" "$PKGS_BIN/lb")
  lb completions > "$PKGS_COMPLETIONS/lb"
}

source_tar "seanenck/lockbox"
