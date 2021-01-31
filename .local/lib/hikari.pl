#!/usr/bin/perl
use strict;
use warnings;

my $home    = $ENV{"HOME"};
my $trigger = $home . "/.cache/.hikari.trigger";
my $config  = $home . "/.cache/.hikari.conf";
if (!@ARGV) {
    die "command required";
}

my $cmd = shift @ARGV;

sub reconfigure {
    my @use = ("template");
    if ( -e $ENV{"IS_LAPTOP"} ) {
        push @use, "laptop";
    }
    elsif ( -e $ENV{"IS_DESKTOP"} ) {
        push @use, "desktop";
    }
    system("rm -f $config");
    for (@use) {
        system("cat $home/.config/hikari/$_.conf >> $config");
    }

}

if ( $cmd eq "start" ) {
    system("rm -f $trigger");
    while ( ! -e $trigger ) {
        reconfigure;
        system("rm -f /tmp/.hikari.*");
        system("hikari -c $config > $home/.cache/hikari.log 2>&1");
    }
} elsif ( $cmd eq "reconfigure" ) {
    reconfigure;
} elsif ( $cmd eq "kill" ) {
    system("touch $trigger");
}
