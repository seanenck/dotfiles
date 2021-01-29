#!/usr/bin/perl
use strict;
use warnings;

my $dir = $ENV{"HOME"} . "/.local/containers/";

my $containers =
`find $dir -type f -name "*.Dockerfile" -exec basename {} \\; | sed 's/\.Dockerfile//g'`;

if ( !@ARGV ) {
    print "clean $containers";
    exit 0;
}

my $cmd = shift @ARGV;

if ( $cmd eq "clean" ) {
    system("podman ps -a -q | xargs podman rm");
    exit 0;
}

my $file = "${dir}$cmd.Dockerfile";
die "unknown container: $cmd" if !-e $file;

my $tag = "$cmd";
my $run = "";
if ( $cmd eq "youtube-dl" ) {
    $run = "--volume=/home/enck/downloads:/build $tag youtube-dl";
    my $target = shift @ARGV;
    die "no target URL given" if !$target;
    $run = "$run '$target'";
}
elsif ( $cmd eq "imagemagick" ) {
    my $sub = join( " ", @ARGV );
    die "no sub-commands given" if !$sub;
    $run = "--volume=/home/enck/downloads:/build $tag $sub";
}

die "unknown command: $cmd" if !$run;

die "unable to build" if system("podman build --tag $tag -f $file") != 0;

system("podman run $run");
