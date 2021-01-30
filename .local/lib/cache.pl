#!/usr/bin/perl
use warnings;
use strict;

my $home = $ENV{"HOME"};
my $bin  = "perl $home/.local/lib/cache.pl";

if (@ARGV) {
    my $command = $ARGV[0];
    if ( $command eq "cleanup" ) {
        my $cleanup_date = `date +%Y-%m-%d`;
        chomp $cleanup_date;
        my $cleanup_dir = "$home/.local/tmp/cleanup/";
        if ( !-d $cleanup_dir ) {
            mkdir $cleanup_dir;
        }
        my $cleanup = $cleanup_dir . $cleanup_date;
        exit if -e $cleanup;
        for ( ( "undo", "swap", "backup" ) ) {
            my $vim_dir = "$home/.vim/$_/";
            if ( -d $vim_dir ) {
                system("find $vim_dir -type f -mtime +1 -delete");
            }
        }
        my $history_root = "$home/.local/var/history/";
        my $history_dir  = "$history_root$cleanup_date";
        system("mkdir -p $history_dir");
        system("rsync -ar $home/.mozilla/ $history_dir/mozilla");
        system("cp .bash_history $history_dir/bash_history");
        my $cnt = 0;

        for my $cleanup (`ls $history_root | sort -r`) {
            $cnt++;
            system("rm -rf $history_root$cleanup") if ( $cnt > 3 );
        }
        system("touch $cleanup");
    }
    elsif ( $command eq "backup" ) {
        if ( -e $ENV{"IS_LOCAL"} ) {
            my $server = $ENV{"LOCAL_SERVER"};
            chomp $server;
            system(
"rsync -av /var/cache/voidedtech/backup/ rsync://$server/backup/"
            );
            system(
"rsync -av --delete-after rsync://$server/pull $home/.local/var/wiki"
            );
        }
    }
    else {
        die "unknown command: $command";
    }
    exit 0;
}

system("$bin cleanup");
system("$bin backup");
