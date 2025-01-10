#!/bin/sh -e
latest_release() {
  _github_latest_release "$1" "$2" "browser_download_url"
}

tagged_release() {
  _github_latest_release "$1" "" "tag_name"
}

_github_latest_release() {
  [ -z "$API_TOKEN" ] && echo "no API_TOKEN set" && exit 1
  [ -z "$1" ] && echo "no release name set" && exit 1
  curl --silent -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $API_TOKEN" \
    "https://api.github.com/repos/$1/releases/latest" | \
    grep "$3" | \
    cut -d ":" -f 2- | \
    tr -d ' ' | \
    sed 's/,$//g' | \
    sort | \
    grep "$2" | \
    sed 's/"//g' | \
    head -n 1
}

source_tar() {
  [ -z "$1" ] && echo "no repository given" && exit 1
  tag=$(tagged_release "$1")
  [ -z "$tag" ] && echo "no tag found for $2" && exit 1
  export PKGS_TAG="$tag"
  download "$1" "" "https://github.com/$1/archive/$tag.tar.gz" "$(basename "$1")-"
}
