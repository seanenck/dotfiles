#!/bin/sh -e
latest_release() {
  [ -z "$API_TOKEN" ] && echo "no API_TOKEN set" && exit 1
  [ -z "$1" ] && echo "no release name set" && exit 1
  [ -z "$2" ] && echo "no release filter set" && exit 1
  curl --silent -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $API_TOKEN" \
    "https://api.github.com/repos/$1/releases/latest" | \
    grep 'browser_download_url' | \
    cut -d ":" -f 2- | \
    tr -d ' ' | \
    sort | \
    grep "$2" | \
    sed 's/"//g' | \
    head -n 1
}

source_tar() {
  [ -z "$1" ] && echo "no repository given" && exit 1
  tag=$(git_tags "https://github.com/$1" | grep -v '{}$' | rev | cut -d "/" -f 1 | rev | head -n 1)
  [ -z "$tag" ] && echo "no tag found" && exit 1
  export PKGS_TAG="$tag"
  download "$1" "" "https://github.com/$1/archive/$tag.tar.gz" "$(basename "$1")-"
}
