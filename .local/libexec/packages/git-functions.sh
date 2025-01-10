#!/bin/sh -e
git_tags() {
  [ -z "$1" ] && echo "no repository given" && exit 1
  git -c versionsort.suffix=- ls-remote --tags --sort=-v:refname "$1"
}

nvim_plugin() {
  plugins="$HOME/.config/nvim/pack/plugins/start/"
  mkdir -p "$plugins"
  git_deploy "$1" "$plugins"
}

git_deploy() {
  [ -z "$1" ] && echo "repository required" && exit 1
  [ -z "$2" ] && echo "target required" && exit 1
  base="$(basename "$1")"
  dest="${2}$base"
  echo "updating repository: $base"
  [ -d "$dest" ] || git clone --quiet "https://github.com/$1" "$dest"
  git -C "$dest" pull --quiet
}
