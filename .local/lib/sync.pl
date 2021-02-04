#!/usr/bin/perl
use strict;
use warnings;

my $last = ".lastsync";
my $home = $ENV{"HOME"};
my $dir  = "$home/sync/";
my $sync = "$home/.local/tmp/sync/";
system("mkdir -p $sync") if !-d $sync;

my $self;
my $other;
if ( -e $ENV{"IS_LAPTOP"} ) {
    exit 0 if !-e $ENV{"IS_LOCAL"};
    $self  = "laptop";
    $other = "desktop";
}
elsif ( -e $ENV{"IS_DESKTOP"} ) {
    $self  = "desktop";
    $other = "laptop";
}
else {
    die "unable to determine sync settings";
}

my $from = "${dir}$self";
die "no sync directory found" if !-d $from;

my $hash = "${sync}hashes";
my $prev = "$hash.prev";
system("find $from -type f -not -name $last -exec md5sum {} \\; > $hash");
my $do = 1;
if ( -e $prev ) {
    if ( system("diff -u $prev $hash > /dev/null") == 0 ) {
        $do = 0;
    }
}
system("cp $hash $prev");

my $server = "rsync://" . $ENV{"LOCAL_SERVER"} . "/sync/";
if ( $do == 1 ) {
    system("date +%Y-%m-%d-%H-%M-%S > $from/$last");
    system("rsync -avc --delete-after $from/ $server$self");
}

my $other_last = "${sync}$other$last";
my $other_dir  = "${dir}$other";
my $other_curr = "$other_dir/$last";
system("rsync -c $server/$other/$last $other_dir");
$do = 1;
if ( -e $other_last ) {
    if ( system("diff -u $other_last $other_curr > /dev/null") == 0 ) {
        $do = 0;
    }
}

system("cp $other_curr $other_last");
if ( $do == 1 ) {
    system("rsync -avc --delete-after $server/$other/ $dir/$other");
}
