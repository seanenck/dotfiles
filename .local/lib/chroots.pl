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
    system("arch-nspawn \$CHROOT/root $command");
    print "\n";
}

for (`schroot --list | grep "source"`) {
    chomp;
    header "$_";
    system("sudo schroot -c $_ -- $command");
    print "\n";
}
