#!/bin/sh -e
unpack() {
  extract_source_tar "$1" "gopls"
  dir=$(app_dir "gopls")
  (cd "$dir/gopls" && go build -buildmode=pie -mod=readonly -modcacherw -ldflags "-compressdwarf=false" -o gopls)
  (cd "$dir/gopls" && install -Dm755 "$PWD/gopls" "$PKGS_BIN/gopls")
}

source_tar "github" "golang/tools"
