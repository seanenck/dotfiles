#!/bin/sh -e
_download() {
  case "$1" in
    "sharkdp/bat")
      STRIP=1 _tarunpack "$tmpbase" "bat"
      ;;
    "dandavison/delta")
      STRIP=1 _tarunpack "$tmpbase" "delta"
      ;;
    "koalaman/shellcheck")
      STRIP=1 _tarunpack "$tmpbase" "shellcheck"
      ;;
    "FilenCloudDienste/filen-cli")
      if ! file "$tmpbase" | grep -q "ELF 64-bit LSB executable"; then
        echo "invalid download"
        return
      fi
      ;;
    "casey/just")
      _tarunpack "$tmpbase" "just"
      just --completions bash > "$COMPLETIONS/just"
      ;;
    "BurntSushi/ripgrep")
      STRIP=1 _tarunpack "$tmpbase" "rg"
      rg --generate=complete-bash > "$COMPLETIONS/rg"
      ;;
    "golang/go")
      STRIP=1 _is_app "$tmpbase" "go" "bin/go"
      ;;
    "seanenck/git-tools")
      _src_bld "$tmpbase" "just --quiet"
      ;;
    *)
      echo "unknown deployment: $1"
      return
      ;;
  esac
  mv "$tmpbase" "$base"
}

_git_tags() {
  git -c versionsort.suffix=- ls-remote --tags --sort=-v:refname "$1"
}

_go_update() {
  tag=$(_git_tags "https://github.com/golang/go" | grep "refs/tags/go" | grep '\.[0-9]\+$' | rev | cut -d '/' -f 1 | rev | head -n 1)
  _download "golang/go" "" "https://go.dev/dl/$tag.linux-arm64.tar.gz"
}

_src() {
  tag=$(_git_tags "https://github.com/$1" | grep -v '{}$' | rev | cut -d "/" -f 1 | rev | head -n 1)
  _download "$1" "" "https://github.com/$1/archive/$tag.tar.gz" "$(basename "$1")-"
}

mkdir -p "$DIR"
[ -z "$TOKEN" ] && echo "no github token found/set" && exit 1
export API_TOKEN="$TOKEN"
_download "sharkdp/bat" "$ARCH-unknown-linux-$LIBC"
_download "dandavison/delta" "$ARCH-unknown-linux-$LIBC"
_download "koalaman/shellcheck" "linux\.$ARCH"
_download "FilenCloudDienste/filen-cli" "linux-x64"
_download "casey/just" "$ARCH-unknown-linux"
_download "BurntSushi/ripgrep" "$ARCH-unknown-linux-gnu"
_go_update
_src "seanenck/git-tools"

# age
# gittools
# gofumpt
# gopls
# lb
# neovim
# revive
# staticcheck
