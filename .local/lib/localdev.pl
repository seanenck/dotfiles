#!/usr/bin/perl
use strict;
use warnings;

my $command  = shift @ARGV;
my $script   = $ENV{"HOME"} . "/.local/lib/localdev.pl";
my $localdev = "/opt/pacman";

if ( !$command ) {
    exit 0;
}

if ( $command eq "dl" ) {
    if ( -d $localdev ) {
        system("perl $script dlbg &");
    }
}
elsif ( $command eq "dlbg" ) {
    if ( system("wsw online") == 0 ) {
        system(
"rsync -avc --delete-after rsync://novel.voidedtech.com/repo/ $localdev 2>&1 | systemd-cat -t localdev"
        );
    }
}
