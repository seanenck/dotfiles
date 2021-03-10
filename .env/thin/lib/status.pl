#!/usr/bin/perl
use warnings;
use strict;

my $home   = $ENV{"HOME"};
my $lib    = "$home/.env/thin/lib/";
my $status = "perl ${lib}status.pl ";
my $etc    = "/var/cache/drudge/backup";
chomp( my $cache = `drudge config directories.tmp` ) or die "no tempdir";
$cache = "$cache/polling/";
my $cache_tmp = "cached.";
my $suppress  = "${cache}${cache_tmp}suppress";
my $no_net    = "${cache}offline";

if (@ARGV) {
    my $command = $ARGV[0];
    if ( $command eq "sync" ) {
        system("mkdir -p $cache");
        my $checking = "$cache/${cache_tmp}check";
        system("find $cache -type f -name '$cache_tmp*' -mmin +1 -delete");
        exit 0 if -e $suppress;
        if ( !-e $checking ) {
            if ( system("ping -c1 -w5 shelf > /dev/null 2>&1") == 0 ) {
                unlink $no_net if -e $no_net;
            }
            else {
                system("touch $no_net");
            }
            system("touch $checking");
        }
        exit 0 if -e $no_net;
        system("drudge arch.pull");
        chomp( my $cache = `drudge config directories.tmp` );
        chomp( my $today = `date +%Y%m%d%P` );
        my $hist   = "$cache/history/";
        my $backup = "$hist$today/";
        exit 0 if -d $backup;
        chomp( my $name = `ls $etc | sort -r | head -n 1 | cut -d "." -f 1` );
        system("rsync -avc --delete-after $etc/ rsync://library/etc/$name");
        system("mkdir -p $backup");

        for ( ( "$home/.mozilla", "$home/.bash_history" ) ) {
            system("rsync -acv $_ $backup/");
        }
        my $count = 0;
        for (`ls $hist | sort -r`) {
            chomp;
            next if !$_;
            $count++;
            if ( $count > 3 ) {
                system("rm -rf $hist$_");
            }
        }
    }
    elsif ( $command eq "waybar" ) {
        system("$status poll | grep '^{.*'");
    }
    elsif ( $command eq "suppress" ) {
        system("touch $suppress");
    }
    elsif ( $command eq "daemon" ) {
        system("$status > $home/.cache/status.log 2>&1");
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
    system("$status backlight &");
    sleep 1;
}
