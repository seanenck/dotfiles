#!/bin/sh -e
download() {
  release=$(latest_release "$1" "$2")
  [ -z "$release" ] && echo "no release found: $1" && exit 1
  base="${PKGS_DIR}/$(basename "$release")"
  [ -e "$base" ] && return
  echo "downloading release for $1"
  echo "  -> $release"
  tmpbase="${base}.tmp"
  curl -L --silent "$release" > "$tmpbase"
  unpack "$tmpbase"
  mv "$tmpbase" "$base"
}
