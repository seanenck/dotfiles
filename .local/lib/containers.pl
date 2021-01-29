#!/usr/bin/perl
use strict;
use warnings;

my $home  = $ENV{"HOME"} . "/.local/";
my $dir   = "${home}containers/";
my $cache = "${home}tmp/containers/";
system("mkdir -p $cache") if !-d $cache;

my $containers =
`find $dir -type f -name "*.Dockerfile" -exec basename {} \\; | sed 's/\.Dockerfile//g'`;

if ( !@ARGV ) {
    print "clean purge $containers";
    exit 0;
}

my $cmd = shift @ARGV;

if ( $cmd eq "clean" or $cmd eq "purge" ) {
    system("podman ps -a -q | xargs podman rm");
    if ( $cmd eq "purge" ) {
        system("podman image list --quiet | xargs podman image rm --force");
        system("rm -rf $cache");
    }
    exit 0;
}

my $file = "${dir}$cmd.Dockerfile";
die "unknown container: $cmd" if !-e $file;

my $hash = "${cache}$cmd";
my $prev = "$hash.prev";
system("sha256sum $file > $hash");
my $must_build = 1;
if ( -e $prev ) {
    if ( system("diff -u $hash $prev > /dev/null") == 0 ) {
        print "no rebuild required\n";
        $must_build = 0;
    }
}

my $tag  = "$cmd";
my $run  = "";
my $opts = "--volume=/home/enck/downloads:/build";
if ( $cmd eq "youtube-dl" ) {
    $run = "youtube-dl";
    my $target = shift @ARGV;
    die "no target URL given" if !$target;
    $run = "$run '$target'";
}
elsif ( $cmd eq "imagemagick" ) {
    my $sub = join( " ", @ARGV );
    die "no sub-commands given" if !$sub;
    $run = "$sub";
}
elsif ( $cmd eq "pyxstitch" ) {
    my $sub = join( " ", @ARGV );
    die "no sub-commands given" if !$sub;
    $run = "pyxstitch $sub";
}
elsif ( $cmd eq "eltorito" ) {
    my $src  = shift @ARGV;
    my $dest = shift @ARGV;
    die "source/dest required" if !$src or !$dest;
    $run = "eltorito $src $dest";
}
elsif ( $cmd eq "kxstitch" ) {
    my $display = $ENV{"DISPLAY"};
    $opts = "$opts -ti -e DISPLAY=$display -v /tmp/.X11-unix:/tmp/.X11-unix";
    $run  = "kxstitch";
}
else {
    die "unknown command: $cmd";
}

$run = "$opts $tag $run";

if ( $must_build > 0 ) {
    die "unable to build" if system("podman build --tag $tag -f $file") != 0;
}
system("mv $hash $prev");

system("podman run --rm $run");
