#!/bin/sh -e
unpack() {
  extract_source_tar "$1" "gofumpt"
  dir=$(app_dir "gofumpt")
  (cd "$dir" && go build -trimpath -mod=readonly -modcacherw)
  (cd "$dir" && install -Dm755 "$PWD/gofumpt" "$PKGS_BIN/gofumpt")
}

source_tar "github" "mvdan/gofumpt"
