#!/bin/sh -e
[ "$PKGS_UNAME" != "Linux" ] && return
grep -q '^ID=alpine$' /etc/os-release || return
if grep '^ID=' /etc/os-release | grep -q -v '^ID=alpine$'; then
  return
fi

unpack() {
  if ! file "$1" | grep -q "ISO 9660 CD-ROM"; then
    echo "invalid download"
    exit 1
  fi
}

tag=$(git_tags "https://gitlab.alpinelinux.org/alpine/aports.git/" | grep "refs/tags/v[0-9]" | grep '\.[0-9]\+$' | rev | cut -d '/' -f 1 | rev | head -n 1 | sed 's/^v//g')
major=$(echo "$tag" | cut -d "." -f 1)
minor=$(echo "$tag" | cut -d "." -f 2)
download "alpine/aports" "" "https://dl-cdn.alpinelinux.org/alpine/v$major.$minor/releases/$PKGS_ARCH/alpine-standard-$tag-$PKGS_ARCH.iso"
pkgver=$(curl --silent -L "https://gitlab.alpinelinux.org/alpine/aports/-/raw/$major.$minor-stable/main/linux-lts/APKBUILD?ref_type=heads" | grep -E '^(pkgver|pkgrel)=' | cut -d "=" -f 2- | tr '\n' '-' | sed 's/-$//g')
[ -z "$pkgver" ] && echo "unable to read alpine pkgver for kernel" && return
kernel="$(uname -r | rev | cut -d "-" -f 2- | rev)"
[ "$pkgver" != "$kernel" ] && echo "$pkgver != $kernel" && exit 1
echo "alpine version checked"
