#!/bin/sh -e
unpack() {
  extract_tar "$1" "just"
  just --completions bash > "$PKGS_COMPLETIONS/just"
}

download "casey/just" "$PKGS_ARCH-unknown-linux"
