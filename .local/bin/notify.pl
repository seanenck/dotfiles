#!/usr/bin/perl
use warnings;
use strict;
use File::Compare;
use File::Copy qw(move);

my $home     = $ENV{"HOME"};
my @dirs     = ( $home . "/.git", "/etc/.git", "/etc/personal/.git", $home . "/store/personal/notebook/.git" );
for ( "workspace", "store" ) {
    my $found = `find $home/$_/ -maxdepth 3 -type d -name ".git" | tr '\n' ' '`;
    chomp $found;
    push @dirs, split( / /, $found );
}

sub notify {
    my $id   = shift @_;
    my $text = shift @_;
    system("dunstify -C $id");
    $text =~ s/:/\n└/g;
    system("dunstify -r $id -t 30000 '$text'");
}

my $cnt = 1000;
for my $dir (@dirs) {
    $cnt++;
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
        notify $cnt, "git: $dname [$count]";
    }
}

$cnt = 1100;
my $imap = "$home/store/personal/imap/fastmail";
if ( -d $imap ) {
    for (`find $imap -type d -name new -exec dirname {} \\; | grep -v Trash`) {
        chomp;
        $cnt++;
        my $count = `ls "$_/new/" | wc -l`;
        chomp $count;
        if ( $count > 0 ) {
            my $dname = $_;
            $dname =~ s#$imap/##g;
            notify $cnt, "mail: $dname [$count]";
        }
    }
}

$cnt = 1200;
for my $pacman (("qdt", "m")) {
    $cnt += 100;
    for (`pacman -Q$pacman`) {
        $cnt++;
        chomp;
        next if !$_;
        notify $cnt, "orphan: $_";
    }
}

$cnt = 2000;
for my $cache ( ( "/var/cache/pacman/pkg", "/srv/http/pacman-cache" ) ) {
    $cnt++;
    if ( -d $cache ) {
        my $packages =
`du -hs $cache | tr '\t' ' ' | cut -d " " -f 1 | grep "G" | sed "s/G//g" | cut -d "." -f 1`;
        chomp $packages;
        if ($packages) {
            if ( $packages > 10 ) {
                notify $cnt, "pkgcache: $packages (G)";
            }
        }
    }
}

my $kernel = 1;
for ( ("linux") ) {
    if ( `uname -r | sed "s/-arch/.arch/g;s/-lts//g"` eq
        `pacman -Qi $_ | grep Version | cut -d ":" -f 2 | sed "s/ //g"` )
    {
        $kernel = 0;
    }
}

$cnt = 2100;
if ( $kernel == 1 ) {
    notify $cnt, "kernel: linux";
}
