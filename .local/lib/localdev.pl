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
    my $tmpfile = "/tmp/localdev/";
    system("mkdir -p $tmpfile");
    if ( system("wsw online") == 0 ) {
        $tmpfile = $tmpfile . `date +%Y%m%d.%H`;
        chomp $tmpfile;
        if ( -e $tmpfile ) {
            exit 0;
        }
        system(
"rsync -avc --delete-after voidedtech.com:/opt/pacman/ $localdev 2>&1 | systemd-cat -t localdev"
        );
        system("touch $tmpfile");
    }
}
