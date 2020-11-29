#!/usr/bin/perl
use strict;
use warnings;

my $tmpdir  = "/tmp/locker/";
my $no_zzz  = $tmpdir . "nozzz";
my $no_lock = $tmpdir . "nolock";

if ( !-d $tmpdir ) {
    mkdir $tmpdir;
}

sub do_lock {
    if ( -e $no_lock ) {
        return;
    }
    return if system("pgrep -x i3lock > /dev/null") == 0;
    system("sys dim");
    system("sleep 0.1");

    system("i3lock -c 333333");
    my $mode  = shift @_;
    my $count = 0;

    # 5 minutes
    my $timeout = 300;
    my $charge  = `status charging`;
    if ( $charge eq "+" ) {

        # 4 hours
        $timeout = $timeout * 48;
    }
    if ( $mode == 1 ) {
        $count = $timeout + 1;
    }
    my $can_suspend = 1;
    while (1) {
        last if ( system("pgrep -x i3lock > /dev/null") != 0 );
        sleep 1;
        $count++;
        if ( !-e $no_zzz ) {
            if ( $count > $timeout and $can_suspend > 0 ) {
                my $suspend = 1;
                if ( -e "/usr/bin/acpi" ) {
                    system("sys volume-reset");
                    system("status sleep");
                    system("pkill $_") for ( ("vlc") );
                }
                else {
                    $suspend = $mode;
                }
                if ( $suspend == 1 ) {
                    system("systemctl suspend");
                    $can_suspend = 0;
                }
                $count = 0;
            }
        }
    }

    system("sys rebright");
    system("xset -display :0 dpms force on");
}

my $command = "lock";
$command = shift @ARGV if (@ARGV);

if ( $command eq "lock" ) {
    do_lock(0);
}
elsif ( $command eq "sleep" ) {
    do_lock(1);
}
elsif ( $command eq "locked" ) {
    if ( -e $no_zzz ) {
        print "NO_SLEEP";
    }
    elsif ( -e $no_lock ) {
        print "UNLOCKED";
    }
}
elsif ( $command eq "locking" ) {
    system("pkill status");
    if ( -e $no_zzz ) {
        unlink $no_zzz;
    }
    else {
        if ( -e $no_lock ) {
            unlink $no_lock;
            system("touch $no_zzz");
        }
        else {
            system("touch $no_lock");
        }
    }
}

