#!/bin/sh -e
[ "$PKGS_UNAME" != "Linux" ] && return

unpack() {
  extract_source_tar "$1" "gofumpt"
  dir=$(app_dir "gofumpt")
  (cd "$dir" && go build -trimpath -mod=readonly -modcacherw)
  (cd "$dir" && install -Dm755 "$PWD/gofumpt" "$PKGS_BIN/gofumpt")
}

source_tar "mvdan/gofumpt"

unpack() {
  extract_source_tar "$1" "gopls"
  dir=$(app_dir "gopls")
  (cd "$dir/gopls" && go build -buildmode=pie -mod=readonly -modcacherw -ldflags "-compressdwarf=false" -o gopls)
  (cd "$dir/gopls" && install -Dm755 "$PWD/gopls" "$PKGS_BIN/gopls")
}

source_tar "golang/tools"

unpack() {
  extract_source_tar "$1" "staticcheck"
  dir=$(app_dir "staticcheck")
  (cd "$dir" && go build -mod=readonly -modcacherw -ldflags "-compressdwarf=false" -o staticcheck ./cmd/staticcheck)
  (cd "$dir/staticcheck" && install -Dm755 "$PWD/staticcheck" "$PKGS_BIN/staticcheck")
}

source_tar "dominikh/go-tools" '[0-9]$'

unpack() {
  extract_source_tar "$1" "revive"
  dir=$(app_dir "revive")
  (cd "$dir" && go build -buildmode=pie -trimpath -modcacherw)
  (cd "$dir" && install -Dm755 "$PWD/revive" "$PKGS_BIN/revive")
}

source_tar "mgechev/revive"

unpack() {
  extract_source_tar "$1" "age"
  dir=$(app_dir "age")
  (cd "$dir" && go build -mod=readonly -modcacherw -ldflags "-X main.Version=$PKGS_TAG" -o . ./...)
  for file in age age-keygen; do
    (cd "$dir" && install -Dm755 "$PWD/$file" "$PKGS_BIN/$file")
  done
}

source_tar "FiloSottile/age"
