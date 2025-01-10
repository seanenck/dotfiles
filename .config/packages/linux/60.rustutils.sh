#!/bin/sh -e
unpack() {
  extract_tar "$1" "delta" 1
}

download "dandavison/delta" "$PKGS_ARCH-unknown-linux-$PKGS_LIBC"

unpack() {
  extract_tar "$1" "rg" 1
  rg --generate=complete-bash > "$PKGS_COMPLETIONS/rg"
}

download "BurntSushi/ripgrep" "$PKGS_ARCH-unknown-linux-gnu"

unpack() {
  extract_tar "$1" "bat" 1
}

download "sharkdp/bat" "$PKGS_ARCH-unknown-linux-$PKGS_LIBC"
