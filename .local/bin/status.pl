#!/usr/bin/perl
use warnings;
use strict;

my $home   = $ENV{"HOME"};
my $bin    = "$home/.local/bin/";
my $status = "perl ${bin}status.pl ";

if (@ARGV) {
    my $command = $ARGV[0];
    if ( $command eq "notify" ) {
        system("perl ${bin}notify.pl");
    }
    elsif ( $command eq "online" ) {
        my %checks;
        $checks{"IS_ONLINE"} = "voidedtech.com";
        $checks{"IS_LOCAL"}  = `source $home/.variables && echo \$SERVER`;
        for ( keys %checks ) {
            my $object = $checks{$_};
            chomp $object;
            my $is_online = `source ~/.variables && echo \$$_`;
            chomp $is_online;
            if ( system("ping -c1 -w5 $object >/dev/null 2>&1") == 0 ) {
                system("touch $is_online");
            }
            else {
                unlink $is_online if -e $is_online;
            }
        }
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

my $display = $ENV{"DISPLAY"};

my $cnt = 1;
while (1) {
    if ( !$display ) {
        sleep 5;
        next;
    }
    $cnt++;
    if ( $cnt % 15 == 0 ) {
        system("$status online &");
        system("$status notify &");
    }
    system("$status backlight &");
    sleep 1;
}
