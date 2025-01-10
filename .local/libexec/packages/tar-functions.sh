#!/bin/sh -e
extract_tar() {
  [ -z "$1" ] && echo "tar file required" && exit 1
  offset=""
  args=""
  if [ -n "$3" ]; then
    args="--strip-components=$3"
    offset="$(tar tf "$1" | cut -d '/' -f $3 | sort -u | sed 's/\n//g')/"
  fi
  tar -xf "$1" $args -C "$PKGS_BIN" "$offset$2"
}

app_dir() {
  echo "$PKGS_ROOT/$1.pkgs.app"
}

extract_tar_app() {
  [ -z "$1" ] && echo "tar file required" && exit 1
  [ -z "$2" ] && echo "name required" && exit 1
  dest=$(app_dir "$2")
  while [ -d "$dest" ]; do
    find "$dest" -delete
  done
  args=""
  [ -n "$4" ] && args="--strip-components=$4"
  mkdir -p "$dest"
  tar xf "$1" $args -C "$dest"
  [ -z "$3" ] && return
  ln -sf "$dest/$3" "$PKGS_BIN/$(basename "$3")"
}

extract_source_tar() {
  extract_tar_app "$1" "$2" "" 1
}
