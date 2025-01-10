#!/bin/sh -e
latest_release() {
  _github_latest_release "$1" "$2" "browser_download_url"
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
    sort | \
    grep "$2" | \
    sed 's/"//g' | \
    head -n 1
}

source_tar() {
  [ -z "$1" ] && echo "no mode given" && exit 1
  [ -z "$2" ] && echo "no repository given" && exit 1
  case "$1" in
    "github")
      tag=$(_github_latest_release "$2" "")
      ;;
    "git")
      tag=$(git_tags "https://github.com/$2" | grep -v '{}$' | grep "$3" | rev | cut -d "/" -f 1 | rev | head -n 1)
      ;;
    *)
      echo "unknown mode: $1"
      exit 1
      ;;
  esac
  [ -z "$tag" ] && echo "no tag found for $2" && exit 1
  export PKGS_TAG="$tag"
  download "$2" "" "https://github.com/$2/archive/$tag.tar.gz" "$(basename "$2")-"
}
