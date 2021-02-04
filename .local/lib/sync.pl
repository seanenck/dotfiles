#!/usr/bin/perl
use strict;
use warnings;

my $home = $ENV{"HOME"};
if (@ARGV) {
    my $cmd = shift @ARGV;
    die "invalid command: $cmd" if $cmd ne "run";
}
else {
    my $count = 0;
    while (1) {
        if ( $count >= 15 ) {
            system("perl $home/.local/lib/sync.pl run");
            $count = 0;
        }
        system("sleep 1");
        $count += 1;
    }
    exit 0;
}

my $last = ".lastsync";
my $dir  = "/opt/sync/";
my $sync = "$home/.local/var/sync/";
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

my $date_time = `date +%Y%m%d%p`;
chomp $date_time;
my $pulling   = 1;
my $prev_time = "$sync/time";
my $hash      = "${sync}hashes." . $date_time;
my $prev      = "$hash.prev";
my $lastmod   = "${sync}lastmod." . $date_time;
system("touch $hash $prev $lastmod $prev_time");
system("find $sync -type f -mtime +1 -delete");
my $curr_timestamp = `date +%s` + 0;
my $last_timestamp = 0;

if ( -s $prev_time ) {
    $last_timestamp = `cat $prev_time` + 0;
}
system("echo $curr_timestamp > $prev_time");
my $delta = $curr_timestamp - $last_timestamp;
if ( $delta < 300 ) {
    $pulling = 0;
}

my $from = "${dir}outbound";
die "no sync directory found" if !-d $from;

my $do   = 1;
my $find = "find $from -type f -not -name $last";
my $mod_time =
  `$find -printf \"%TY-%Tm-%Td %TH:%TM:%TS\n\" | sort -r | head -n 1`;
chomp $mod_time;
my $prev_mod = "";
if ( -s $lastmod ) {
    $prev_mod = `cat $lastmod`;
    chomp $prev_mod;
}
if ( $mod_time eq $prev_mod ) {
    $do = 0;
}
else {
    system("$find -exec md5sum {} \\; > $hash");
    if ( system("diff -u $prev $hash > /dev/null") == 0 ) {
        $do = 0;
    }
}
system("echo $mod_time > $lastmod");
system("cp $hash $prev");

my $server = "rsync://" . $ENV{"LOCAL_SERVER"} . "/sync/";
if ( $do == 1 ) {
    print "push $from\n";
    system("date +%Y-%m-%d-%H-%M-%S > $from/$last");
    system("rsync -avc --delete-after $from/ $server$self");
}

if ( $pulling == 0 ) {
    exit 0;
}

print "pulling $other\n";
my $other_last = "${sync}$other$last";
my $other_dir  = "${dir}inbound";
my $other_curr = "$other_dir/$last";
system("mkdir -p $other_dir") if !-d $other_dir;
system("rsync -c $server/$other/$last $other_dir");
$do = 1;
if ( -e $other_last ) {
    if ( system("diff -u $other_last $other_curr > /dev/null") == 0 ) {
        $do = 0;
    }
}

system("cp $other_curr $other_last");
if ( $do == 1 ) {
    system("rsync -avc --delete-after $server/$other/ $other_dir");
}
