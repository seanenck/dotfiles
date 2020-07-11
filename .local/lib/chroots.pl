#!/usr/bin/perl
use strict;
use warnings;

my $command = "pacman -Syyu";
if (@ARGV) {
    $command = join( " ", @ARGV );
}

sub header {
    print "\n=========\n";
    print shift @_;
    print "\n=========\n\n";
}

if ( !@ARGV ) {
    header "builds";
    my $makepkg = "/tmp/makepkg.conf";
    system("cat /etc/makepkg.conf \$HOME/.makepkg.conf > $makepkg");
    system("sudo install -Dm644 $makepkg \$CHROOT/root/etc/makepkg");
    system("arch-nspawn \$CHROOT/root $command");
    print "\n";
    unlink $makepkg;
}

for (`schroot --list | grep "source"`) {
    chomp;
    header "$_";
    system("sudo schroot -c $_ -- $command");
    print "\n";
}
