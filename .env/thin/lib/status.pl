#!/usr/bin/perl
use warnings;
use strict;

my $home   = $ENV{"HOME"};
my $lib    = "$home/.env/thin/lib/";
my $status = "perl ${lib}status.pl ";
my $synced = "$home/.sync";
my $etc    = "/var/cache/drudge/backup";
system("mkdir -p $synced") if !-d $synced;
chomp( my $cache = `drudge config directories.tmp` ) or die "no tempdir";
$cache = "$cache/polling/";
my $cache_tmp = "cached.";
my $suppress  = "${cache}${cache_tmp}suppress";
my $no_net    = "${cache}offline";

if (@ARGV) {
    my $command = $ARGV[0];
    if ( $command eq "sync" ) {
        exit 0 if -e $no_net;
        system("drudge arch.pull");
        system("rsync -avc rsync://shelf/sync $synced");
        system("rsync -avc /var/cache/pacman/pkg/ rsync://library/pkgcache");
        chomp( my $cache = `drudge config directories.tmp` );
        chomp( my $today = `date +%Y%m%d%P` );
        my $backup = "$cache/history/$today/";
        exit 0 if -d $backup;
        chomp( my $name = `ls $etc | sort -r | head -n 1 | cut -d "." -f 1` );
        system("rsync -avc --delete-after $etc/ rsync://library/etc/$name");
        system("mkdir -p $backup");

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
    elsif ( $command eq "waybar" ) {
        system("$status poll | grep '^{.*'");
    }
    elsif ( $command eq "suppress" ) {
        system("touch $suppress");
    }
    elsif ( $command eq "poll" ) {
        my $checking = "$cache/${cache_tmp}check";
        system("find $cache -type f -name '$cache_tmp*' -mmin +1 -delete");
        exit 0 if -e $suppress;
        if ( !-e $checking ) {
            my $act = "start";
            if ( system("ping -c1 -w5 shelf > /dev/null 2>&1") == 0 ) {
                unlink $no_net if -e $no_net;
            }
            else {
                $act = "stop";
                system("touch $no_net");
            }
            system( 'systemctl --user ' . $act . ' drudge-session@messaging' );
            system("touch $checking");
        }
        exit 0 if -e $no_net;
        $cache = "$cache/notify";
        system("drudge messaging.reader > $cache");
        if ( -s $cache ) {
            chomp( my $tooltip = `cat $cache` );
            $tooltip =~ s/\n/\\r/g;
            print '{"text": "🔔", "tooltip": "' . $tooltip . '"}', "\n";
        }
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
