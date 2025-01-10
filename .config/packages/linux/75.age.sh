#!/bin/sh -e
unpack() {
  extract_source_tar "$1" "age"
  dir=$(app_dir "age")
  (cd "$dir" && go build -mod=readonly -modcacherw -ldflags "-X main.Version=$PKGS_TAG" -o . ./...)
  for file in age age-keygen; do
    (cd "$dir" && install -Dm755 "$PWD/$file" "$PKGS_BIN/$file")
  done
}

source_tar "github" "FiloSottile/age"
