#!/usr/bin/perl
use warnings;
use strict;
use File::Compare;
use File::Copy qw(move);
use autodie;

my $no_status = "/tmp/nostatus";

if (@ARGV) {
    my $command = $ARGV[0];
    if ( $command eq "displays" ) {
        my $display_cache = $ENV{"HOME"} . "/.cache/displays";
        my $prev_cache    = $display_cache . ".prev";
        system("xrandr | grep ' connected' | cut -d ' ' -f 1 > $display_cache");
        system("touch $prev_cache");
        my $cmp = compare( $display_cache, $prev_cache );
        move $display_cache, $prev_cache;
        if ( $cmp != 0 ) {
            my $workspace = `cat $prev_cache | wc -l` > 1 ? " docked" : "";
            system("workspaces$workspace");
        }
    }
    elsif ( $command eq "toggle" || $command eq "sleep" ) {
        my $change = "on";
        if ( -e "$no_status" || $command eq "sleep" ) {
            system("rm -f $no_status");
        }
        else {
            $change = "off";
            system("touch $no_status");
        }
        if ( $command ne "sleep" ) {
            system("notify-send -t 5000 'notifications: $change'");
        }
    }
    elsif ( $command eq "mail" ) {
        exit if system("ltcten online");
        exit if system("ltcten status | grep -q -E 'home|default'");
        my $mail_file = "/tmp/mail";
        system("mkdir -p $mail_file");
        my $time = `date +%Y-%m-%d-%H-`;
        chomp $time;
        $time .= `date +%M` >= 30 ? "30" : "00";
        $mail_file = $mail_file . "/$time";

        unless ( system("pgrep -x mutt > /dev/null") ) {
            system("rm -f $mail_file");
            exit;
        }
        exit if -e "$mail_file";
        system("mail");
        system("touch $mail_file");
    }
    exit;
}
