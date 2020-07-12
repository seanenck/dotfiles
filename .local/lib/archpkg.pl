#!/usr/bin/perl
use strict;
use warnings;

die "no PKGBUILD" if !-e "PKGBUILD";

for ( ( "log", "tar.zst" ) ) {
    system("rm -f *.$_");
}

my $makepkg = "/tmp/makepkg.conf";
system("cat /etc/makepkg.conf \$HOME/.makepkg.conf > $makepkg");
system("sudo install -Dm644 $makepkg \$CHROOT/root/etc/makepkg.conf");
unlink $makepkg;

die "packaging failed"
  if system("makechrootpkg -c -n -d /var/cache/pacman/pkg -r \$CHROOT") != 0;
