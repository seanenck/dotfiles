#!/usr/bin/perl
use strict;
use warnings;

die "no PKGBUILD" if !-e "PKGBUILD";

for ( ( "log", "tar.xz" ) ) {
    system("rm -f *.$_");
}

die "packaging failed"
  if system("makechrootpkg -c -n -d /var/cache/pacman/pkg -r \$CHROOT") != 0;
