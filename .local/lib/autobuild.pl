#!/usr/bin/perl
use strict;
use warnings;

my $home      = "/opt/autobuild";
my $pkgbuilds = "$home/PKGBUILDs";
my $cache     = "$home/cache";

system("mkdir -p $cache");
system("rm -rf $pkgbuilds");
system("rsync -av /home/enck/.local/PKGBUILDs/ $pkgbuilds");

for my $pkg (`find $pkgbuilds -name "auto" -type f`) {
    chomp $pkg;
    if ( !$pkg ) {
        next;
    }
    my $name = `echo $pkg | cut -d '/' -f 5`;
    chomp $name;
    my $current = $cache . "/$name";
    my $prev    = $current . ".prev";
    my $context = `cat $pkg`;
    chomp $context;
    my @parts = split( ",", $context );
    my $url   = $parts[0];
    my $ref   = $parts[1];
    print "autobuild: $url\n";

    if (
        system(
"git ls-remote --heads --sort=v:refname $url | grep 'refs/heads/$ref' > $current"
        ) != 0
      )
    {
        print "unable to read remote\n";
        next;
    }
    my $build = 1;
    if ( -e $prev ) {
        $build = 0;
        if ( system("diff -u $prev $current") != 0 ) {
            $build = 1;
        }
    }
    if ( $build == 1 ) {
        print "building\n";
        system(
"cd $pkgbuilds/$name &&  makechrootpkg -c -n -d /var/cache/pacman/pkg -r /opt/chroots/builds"
        );
    }
    system("mv $current $prev");
}
