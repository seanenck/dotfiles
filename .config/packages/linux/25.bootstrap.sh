#!/bin/sh -e
unpack() {
  extract_tar_app "$1" "go" "bin/go" 1
}

tag=$(git_tags "https://github.com/golang/go" | grep "refs/tags/go" | grep '\.[0-9]\+$' | rev | cut -d '/' -f 1 | rev | head -n 1)
download "golang/go" "" "https://go.dev/dl/$tag.linux-arm64.tar.gz"

unpack() {
  extract_tar "$1" "just"
  just --completions bash > "$PKGS_COMPLETIONS/just"
}

download "casey/just" "$PKGS_ARCH-unknown-linux"
