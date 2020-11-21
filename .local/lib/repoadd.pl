#!/usr/bin/perl
use strict;
use warnings;

die "no package" if ( !@ARGV );
my $package = shift @ARGV;
die "no package exists: $package" if !-e $package;

die "not a valid package" if ( not $package =~ m/\.tar\./ );
my $basename = `echo $package | rev | cut -d '-' -f 4- | rev`;

my $drop = "/opt/autobuild/drop";
chomp $basename;
system("ssh novel -- find $drop -name '$basename-\*' -delete");
system("scp $package novel:$drop");
