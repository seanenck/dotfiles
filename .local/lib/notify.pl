#!/usr/bin/perl
use warnings;
use strict;
use File::Compare;
use File::Copy qw(move);

my $home = $ENV{"HOME"};
my @dirs = ( $home . "/.git", "/etc/.git" );
for ( "workspace", "store" ) {
    my $found = `find $home/$_/ -maxdepth 3 -type d -name ".git" | tr '\n' ' '`;
    chomp $found;
    push @dirs, split( / /, $found );
}

for my $dir (@dirs) {
    my $dname = `dirname $dir`;
    chomp $dname;
    my $count = 0;
    for my $git (
        "update-index -q --refresh",
        "diff-index --name-only HEAD --",
        "status -sb | grep ahead",
        "ls-files --other --exclude-standard"
      )
    {
        $count += `git -C $dname $git | wc -l`;
    }
    if ( $count > 0 ) {
        $dname =~ s#$home#~#g;
        system("notify-send -t 30000 \"$dname\" [$count]");
    }
}

system("mail status");
system("backup status");

my $packages = `pacman -Qqdt`;
$packages =~ tr/\n/ /;
for ( split( / /, $packages ) ) {
    system("notify-send -t 30000 'orphan: $_'");
}

$packages =
`du -h /var/cache/pacman/pkg | tr '\t' ' ' | cut -d " " -f 1 | grep "G" | sed "s/G//g" | cut -d "." -f 1`;
chomp $packages;
if ( $packages > 10 ) {
    system("notify-send -t 30000 'pkgcache: $packages(G)'");
}

if ( `uname -r | sed "s/-arch/.arch/g"` ne
    `pacman -Qi linux | grep Version | cut -d ":" -f 2 | sed "s/ //g"` )
{
    system("notify-send -t 30000 'linux: kernel'");
}
