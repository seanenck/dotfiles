#!/usr/bin/perl
use strict;
use warnings;

die "no package" if ( !@ARGV );
my $package = shift @ARGV;
die "no package exists: $package" if !-e $package;

die "not a valid package" if ( not $package =~ m/\.tar\./ );
my $repo     = $ENV{"HOME"} . "/store/managed/pacman/";
my $database = "enckse.db.tar.gz";

system("cp $package $repo");
system("cd $repo && repo-add $database $package");

my @purge;
for my $tar (
`find $repo -type f -name "*.tar.xz" -exec basename {} \\; | rev | cut -d "-" -f 4- | rev | sort -u`
  )
{
    chomp $tar;
    for my $file (`ls $repo | grep "^$tar-" | sort -r | tail -n +2`) {
        chomp $file;
        push @purge, $file;
    }
}

if (@purge) {
    print "purge:\n";
    for (@purge) {
        print "  -> $_\n";
    }
    print "delete (Y/n)? ";
    my $line = <STDIN>;
    $line = lc $line;
    chomp $line;
    if ( $line ne "n" ) {
        for (@purge) {
            for (@purge) {
                system("rm -f $repo$_");
            }
        }
    }
}
