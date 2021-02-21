#!/usr/bin/perl
use warnings;
use strict;

my $home   = $ENV{"HOME"};
my $lib    = "$home/.env/thin/lib/";
my $status = "perl ${lib}status.pl ";
my $synced = "$home/.sync";
system("mkdir -p $synced") if !-d $synced;

if (@ARGV) {
    my $command = $ARGV[0];
    if ( $command eq "sync" ) {
        system("drudge arch.pull");
        system("rsync -avc rsync://shelf/sync $synced");
        my $cache = "$home/.cache/backup/";
        chomp( my $today = `date +%Y%m%d%P` );
        my $backup = $cache . $today . "/";
        system("mkdir -p $backup") if !-d $backup;
        for ( ( "$home/.mozilla", "$home/.bash_history" ) ) {
            system("rsync -acv $_ $backup/");
        }
        my $count = 0;
        for (`ls $cache | sort -r`) {
            chomp;
            next if !$_;
            $count++;
            if ( $count > 2 ) {
                system("rm -rf $cache$_");
            }
        }
    }
    elsif ( $command eq "poll" ) {
        system("drudge user.mail > $home/.cache/messages");
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

my $poll = 300;
my $cnt  = $poll;
chomp( my $now = `date +%H` );
while (1) {
    if ( !$ENV{"WAYLAND_DISPLAY"} ) {
        exit 0;
    }
    chomp( my $cur = `date +%H` );
    if ( $cur ne $now ) {
        system("$status sync &");
        $now = $cur;
    }
    $cnt++;
    if ( $cnt > $poll ) {
        system("$status poll &");
        $cnt = 0;
    }
    system("$status backlight &");
    sleep 1;
}
