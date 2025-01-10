#!/bin/sh -e
download() {
  release="$3"
  if [ -z "$release" ]; then
    release=$(latest_release "$1" "$2")
  fi
  [ -z "$release" ] && echo "no release found: $1" && exit 1
  base="${PKGS_DIR}/$4$(basename "$release")"
  [ -e "$base" ] && return
  >&2 echo "downloading release for $2"
  >&2 echo "  -> $1"
  tmpbase="${base}.tmp"
  [ -e "$tmpbase" ] || curl -L --silent "$release" > "$tmpbase"
  [ -z "$tmpbase" ] && return
  unpack "$tmpbase"
  mv "$tmpbase" "$base"
}
