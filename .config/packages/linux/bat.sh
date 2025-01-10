#!/bin/sh -e
unpack() {
  extract_tar "$1" "bat" 1
}

download "sharkdp/bat" "$PKGS_ARCH-unknown-linux-$PKGS_LIBC"
