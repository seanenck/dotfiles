#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

my $bin = $ENV{"HOME"} . "/.bin/";

my $dir = $ENV{"CONTAINER_BASE"};

die "no CONTAINER_BASE set" if !$dir or !-d $dir;

die "sub command required" if !@ARGV;

my $arg = shift @ARGV;

my $script = "${bin}contain-$arg";

die "invalid contain command: $arg" if !-x $script;

system("$script @ARGV");
