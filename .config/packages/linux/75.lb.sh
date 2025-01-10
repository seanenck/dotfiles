#!/bin/sh -e
unpack() {
  extract_source_tar "$1" "lb"
  dir=$(app_dir "lb")
  (cd "$dir" && just --quiet version="$PKGS_TAG")
  (cd "$dir" && install -Dm755 "$PWD/target/lb" "$PKGS_BIN/lb")
  lb completions > "$PKGS_COMPLETIONS/lb"
}

source_tar "github" "seanenck/lockbox"
