#!/bin/sh -e
unpack() {
  extract_source_tar "$1" "staticcheck"
  dir=$(app_dir "staticcheck")
  (cd "$dir" && go build -mod=readonly -modcacherw -ldflags "-compressdwarf=false" -o staticcheck ./cmd/staticcheck)
  (cd "$dir/staticcheck" && install -Dm755 "$PWD/staticcheck" "$PKGS_BIN/staticcheck")
}

source_tar "dominikh/go-tools" '[0-9]$'
