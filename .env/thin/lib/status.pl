#!/usr/bin/perl
use warnings;
use strict;

my $home   = $ENV{"HOME"};
my $lib    = "$home/.env/thin/lib/";
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
        my $pids  = system("pidof swaylock > /dev/null");
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

my $me = "$$";
for (`pidof perl | tr ' ' '\\n'`) {
    chomp;
    if ( $_ eq $me ) {
        next;
    }
    my $cmdline = `cat /proc/$_/cmdline`;
    chomp $cmdline;
    if ( $cmdline =~ m/status.pl/ ) {
        system("kill -1 $_");
    }
}

my $max = 15;
my $cnt = $max + 1;
while (1) {
    $cnt++;
    if ( !$ENV{"WAYLAND_DISPLAY"} ) {
        exit 0;
    }
    if ( $cnt >= $max ) {
        system("$status notify &");
        $cnt = 0;
    }
    system("$status backlight &");
    sleep 1;
}
