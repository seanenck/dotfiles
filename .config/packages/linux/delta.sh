#!/bin/sh -e
unpack() {
  extract_tar "$1" "delta" 1
}

download "dandavison/delta" "$PKGS_ARCH-unknown-linux-$PKGS_LIBC"
