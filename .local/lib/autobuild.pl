#!/usr/bin/perl
use strict;
use warnings;

my $home      = "/opt/autobuild";
my $pkgbuilds = "$home/PKGBUILDs";
my $cache     = "$home/cache";
my $repo      = "$home/repo";
my $next      = "$repo.new";
my $drop      = "$home/drop/";

system("mkdir -p $repo");
system("mkdir -p $next");
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
    my $old = 1;
    my $failed = 0;
    if ( $build == 1 ) {
        print "building\n";
        my $path = "$pkgbuilds/$name";
        my $exit = system(
"cd $path &&  makechrootpkg -c -n -d /var/cache/pacman/pkg -r /opt/chroots/builds"
        );
        if ( $exit != 0 ) {
            print "build failed\n";
            $failed = 1;
        }
        else {
            $old = 0;
            system("cd $path && cp *.zst $next");
        }
    }
    if ( $old == 1 ) {
        print "using previous version in repository\n";
        system("cp $repo/$name* $next");
    }
    if ( $failed == 0 ) {
        system("mv $current $prev");
    }
}

system("cp $drop/*.zst $next");

for my $pkg (`ls $next | grep "\.zst"`) {
    chomp $pkg;
    print $pkg, "\n";
    system("cd $next && repo-add localdev.db.tar.gz $pkg");
}

system("rm -rf $repo");
system("mv $next $repo");
