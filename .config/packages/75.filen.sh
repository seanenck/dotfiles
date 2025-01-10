#!/bin/sh -e
[ "$PKGS_UNAME" != "Linux" ] && return

unpack() {
  if ! file "$1" | grep -q "ELF 64-bit LSB executable"; then
    echo "invalid download"
    exit 1
  fi
}

download "FilenCloudDienste/filen-cli" "linux-x64"
