#!/bin/sh -e
unpack() {
  extract_tar "$1" "rg" 1
  rg --generate=complete-bash > "$PKGS_COMPLETIONS/rg"
}

download "BurntSushi/ripgrep" "$PKGS_ARCH-unknown-linux-gnu"
