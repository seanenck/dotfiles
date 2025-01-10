#!/bin/sh -e
unpack() {
  extract_tar "$1" "shellcheck" 1
}

download "koalaman/shellcheck" "linux\.$ARCH"
