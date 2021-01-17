#!/usr/bin/perl
use warnings;
use strict;
use File::Compare;
use File::Copy qw(move);
use autodie;

my $home         = $ENV{"HOME"};
my $local        = "$home/.local/";
my $bin          = "${local}bin/";
my $status       = "perl ${bin}status.pl ";
my $sys          = "$bin/sys";
my $history_root = "$home/.cache/history/";

if (@ARGV) {
    my $command = $ARGV[0];
    if ( $command eq "mail" ) {
        exit if ( system("$sys online") != 0 );
        my $mail_dir = "/tmp/mail";
        mkdir $mail_dir if !-d $mail_dir;
        my $time = `date +%Y-%m-%d-%H-`;
        chomp $time;
        $time .= `date +%M` >= 30 ? "30" : "00";
        my $mail_file = $mail_dir . "/$time";
        my $mutt      = $mail_dir . "/mutt";

        if ( system("pgrep -x mutt > /dev/null") == 0 ) {
            system("touch $mutt");
            exit;
        }
        if ( -e $mutt ) {
            system("rm -f $mutt $mail_file");
        }

        exit if -e "$mail_file";
        system("$sys mail");
        system("touch $mail_file");
    }
    elsif ( $command eq "notify" ) {
        system("perl ${bin}notify.pl");
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
    elsif ( $command eq "regen" ) {
        my $rcache = "~/.cache/regen";
        my $curr   = "$rcache/current";
        my $prev   = "$curr.prev";
        my $menu   = "~/.fluxbox/usermenu";
        my $apps   = "~/.local/share/applications";
        system("mkdir -p $rcache") if !-d $rcache;
        system("ls $apps/*.app | sort > $curr");
        if ( -e $prev ) {
            if ( system("diff -u $prev $curr") == 0 ) {
                exit 0;
            }
        }
        system("echo [separator] > $menu");
        for my $app (`cat $curr | rev | cut -d '/' -f 1 | rev`) {
            chomp $app;
            if ( !$app ) {
                next;
            }
            my $name = `echo $app | cut -d '.' -f 1`;
            chomp $name;
            system("echo '[exec] ($name) {/bin/bash $apps/$app}' >> $menu");
        }
        system("echo [separator] >> $menu");
        system("mv $curr $prev");
    }
    elsif ( $command eq "cleanup" ) {
        my $cleanup_date = `date +%Y-%m-%d`;
        chomp $cleanup_date;
        my $cleanup_dir = "/tmp/cleanup/";
        if ( !-d $cleanup_dir ) {
            mkdir $cleanup_dir;
        }
        my $cleanup = $cleanup_dir . $cleanup_date;
        exit if -e $cleanup;
        for ( ( "undo", "swap", "backup" ) ) {
            my $vim_dir = "$home/.vim/$_/";
            if ( -d $vim_dir ) {
                system("find $vim_dir -type f -mtime +1 -exec rm {} \\;");
            }
        }
        my $history_dir = "$history_root$cleanup_date";
        system("mkdir -p $history_dir");
        system("rsync -ar $home/.mozilla/ $history_dir/mozilla");
        system("rsync -ar $home/.fluxbox/ $history_dir/fluxbox");
        system("cp .bash_history $history_dir/bash_history");
        my $cnt = 0;
        for my $cleanup (`ls $history_root | sort -r`) {
            $cnt++;
            system("rm -rf $history_root$cleanup") if ( $cnt > 3 );
        }
        system("touch $cleanup");
    }
    elsif ( $command eq "backup" ) {
        system(
"source ~/.variables && perl ${bin}backup.pl | systemd-cat -t backup"
        );
    }
    elsif ( $command eq "wiki" ) {
        my $wiki = "$home/.cache/wiki/";
        my $hash = "${wiki}hash";
        my $prev = $hash . ".prev";
        my $note = "$home/store/config/notebook";
        system("mkdir -p $wiki");
        system("find $note -type f -exec md5sum {} \\; > $hash");
        if ( -e $prev ) {
            exit 0 if ( system("diff -u $prev $hash") == 0 );
        }
        system("mv $hash $prev");
        system(
"zim --export $note --output $wiki/notebook/ --overwrite --index-page index"
        );
    }
    exit;
}

my $cnt = 1;
while (1) {
    $cnt++;
    if ( $cnt % 15 == 0 ) {
        system("$status notify &");
    }
    if ( $cnt >= 30 ) {
        system("$status cleanup &");
        system("$status wiki &");
        system("$status backup &");
        system("$status regen &");
        $cnt = 0;
    }
    system("$status backlight &");
    system("$status mail &");
    sleep 1;
}
