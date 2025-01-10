#!/bin/sh -e
[ "$PKGS_UNAME" != "Linux" ] && return

unpack() {
  extract_tar "$1" "shellcheck" 1
}

download "koalaman/shellcheck" "linux\.$ARCH"
