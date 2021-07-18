#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

my $bin = $ENV{"HOME"} . "/.bin/";

my $dir = $ENV{"CONTAINER_BASE"};

die "no CONTAINER_BASE set" if !$dir or !-d $dir;

die "sub command required" if !@ARGV;

my $arg = shift @ARGV;


if ( $arg eq "help" ) {
    print "build help purge tag start list kill";
    exit;
}
elsif ( $arg eq "tag" or $arg eq "purge" or $arg eq "start" or $arg eq "kill" ) {

    die "container required" if !@ARGV;

    my $container = shift @ARGV;
    my $path = "${dir}192.168.64.$container/";

    die "invalid container: $path" if !-d $path;

    my $sessions = `screen -list | grep "macvm$container\\s*" | awk '{print \$1}'`;
    chomp $sessions;
    if ( $arg eq "kill" ) {
        for my $sess (split("\n", $sessions)) {
            print "killing session object: $sess\n";
            system("screen -X -S $sess quit");
        }
        exit;
    }

    if ($sessions) {
        die "unable to operate on running instance";
    }

    if ( $arg eq "purge" ) {
        system("rm -rf $path");
    } elsif ( $arg eq "start" ) {
        system("screen -D -m -S macvm$container -- bash ${path}start.sh &")
    }
    exit;
}

my $script = "${bin}contain-$arg";

die "invalid contain command: $arg" if !-x $script;

system("$script @ARGV");
