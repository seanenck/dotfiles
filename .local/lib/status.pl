#!/usr/bin/perl
use warnings;
use strict;

my $home   = $ENV{"HOME"};
my $lib    = "$home/.local/lib/";
my $status = "perl ${lib}status.pl ";

if (@ARGV) {
    my $command = $ARGV[0];
    if ( $command eq "notify" ) {
        system("perl ${lib}notify.pl");
    }
    elsif ( $command eq "backlight" ) {
        my $classes = `ls /sys/class/backlight/ | wc -l` + 0;
        if ( $classes == 0 ) {
            exit 0;
        }
        my $pids  = system("pidof i3lock > /dev/null");
        my $light = `brightnessctl get` + 0;
        my $set   = "";
        if ( $light < 1500 ) {
            if ( $pids != 0 ) {
                $set = "50%";
            }
        }
        else {
            if ( $pids == 0 ) {
                $set = "5";
            }
        }
        if ($set) {
            system("brightnessctl set $set > /dev/null");
        }
    }
    exit;
}

my $max = 15;
my $cnt = $max + 1;
while (1) {
    $cnt++;
    if ( $cnt >= $max ) {
        system("$status notify &");
        $cnt = 0;
    }
    system("$status backlight &");
    sleep 1;
}
