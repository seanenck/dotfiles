#!/bin/sh -e
download() {
  echo "checking release: $1"
  release="$3"
  if [ -z "$release" ]; then
    release=$(latest_release "$1" "$2")
  fi
  [ -z "$release" ] && echo "no release found: $1" && exit 1
  prefix="$(echo "$1" | sha256sum | cut -c 1-7)"
  release_name="$(basename "$release")"
  base="${PKGS_DIR}/$prefix.$4$release_name"
  export PKGS_HASH="$prefix"
  [ -e "$base" ] && return
  echo "downloading release for $1"
  echo "  -> url: $1"
  echo "  -> archive: $base"
  tmpbase="${base}.tmp"
  [ -e "$tmpbase" ] || curl -L --silent "$release" > "$tmpbase"
  [ -z "$tmpbase" ] && return
  unpack "$tmpbase"
  mv "$tmpbase" "$base"
  find "${PKGS_DIR}/" -maxdepth 1 -mtime +30 -type f -name "$prefix*" -not -path "*$release_name*" -delete
}
