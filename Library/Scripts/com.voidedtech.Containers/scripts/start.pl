#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

die "container required" if !@ARGV;

my $container = shift @ARGV;

my $dir = $ENV{"CONTAINER_BASE"};

my $path = "${dir}192.168.64.$container/";

die "invalid container: $path" if !-d $path;

system("screen -D -m -S macvm$container -- bash ${path}start.sh &")
