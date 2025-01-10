#!/bin/sh -e
[ "$PKGS_UNAME" = "Linux" ] && return

unpack() {
  echo "  -> noop"
}

download "kovidgoyal/kitty" "dmg"
download "rxhanson/Rectangle" "dmg"
