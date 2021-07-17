#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

my $directory = $ENV{"CONTAINER_BASE"};

die "container required" if !@ARGV;

my $container = shift @ARGV;

my $path = "${directory}192.168.64.$container/";

die "invalid container: $path" if !-d $path;

system("rm -rf $path");
