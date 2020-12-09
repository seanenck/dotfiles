#!/usr/bin/perl
use strict;
use warnings;

my $tmp = "/tmp/backup/";
mkdir $tmp if !-d $tmp;
my $check = `date +%Y-%m-%d.%H`;
chomp $check;
$check = $tmp . $check;

exit 0 if -e $check;

my $server  = $ENV{"SERVER"};
my $mirrors = $ENV{"HOME"} . "/store/personal/mirror/";

if ( system("curl -Is http://$server > /dev/null") != 0 ) {
    print "backup system not available\n";
    exit 0;
}

if ( -d $mirrors ) {
    print "backing up mirrors\n";
    for (`ls $mirrors`) {
        chomp;
        system(
    "rsync -avcr --delete-after $mirrors/$_/ rsync://$server/mirror/$_/"
        );
    }
}

system("rsync -av /var/cache/voidedtech/backup/ rsync://$server/backup/");
system("touch $check");
