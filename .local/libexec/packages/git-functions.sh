#!/bin/sh -e
git_tags() {
  [ -z "$1" ] && echo "no repository given" && exit 1
  git -c versionsort.suffix=- ls-remote --tags --sort=-v:refname "$1"
}
