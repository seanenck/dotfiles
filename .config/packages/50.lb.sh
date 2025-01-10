#!/bin/sh -e
[ "$PKGS_UNAME" = "Linux" ] && return

unpack() {
  tar -zxf "$1" -C "$PKGS_BIN" "lb"
  lb completions > "$PKGS_COMPLETIONS/lb"
}

download "seanenck/lockbox" "darwin-arm64"
