#!/bin/sh -e
download() {
  release="$3"
  if [ -z "$release" ]; then
    release=$(latest_release "$1" "$2")
  fi
  [ -z "$release" ] && echo "no release found: $1" && exit 1
  base="${PKGS_DIR}/$4$(basename "$release")"
  export PKGS_HASH="$(echo "$release" | sha256sum | cut -c 1-7)"
  [ -e "$base" ] && return
  >&2 echo "downloading release for $1"
  >&2 echo "  -> url: $1"
  >&2 echo "  -> archive: $base"
  tmpbase="${base}.tmp"
  [ -e "$tmpbase" ] || curl -L --silent "$release" > "$tmpbase"
  [ -z "$tmpbase" ] && return
  unpack "$tmpbase"
  mv "$tmpbase" "$base"
}