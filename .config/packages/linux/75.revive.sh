#!/bin/sh -e
unpack() {
  extract_source_tar "$1" "revive"
  dir=$(app_dir "revive")
  (cd "$dir" && go build -buildmode=pie -trimpath -modcacherw)
  (cd "$dir" && install -Dm755 "$PWD/revive" "$PKGS_BIN/revive")
}

source_tar "mgechev/revive"
