#!/usr/bin/perl
use warnings;
use strict;
use File::Compare;
use File::Copy qw(move);

my $home = $ENV{"HOME"};
my $dir_env = `source $home/.variables && echo \$GIT_DIRS`;
chomp $dir_env;
my @dirs = split / /, $dir_env;
for ( "workspace", "store" ) {
    my $found = `find $home/$_/ -maxdepth 3 -type d -name ".git" | tr '\n' ' '`;
    chomp $found;
    push @dirs, split( / /, $found );
}

sub notify {
    my $id   = shift @_;
    my $text = shift @_;
    $text =~ s/:/\n└/g;
    system("dunstify -r $id -t 45000 '$text'");
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
my $imap = "$home/store/imap/fastmail";
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
my $kernel = 1;
for ( ("linux") ) {
    if ( `uname -r | sed "s/-arch/.arch/g;s/-lts//g"` eq
        `pacman -Qi $_ | grep Version | cut -d ":" -f 2 | sed "s/ //g"` )
    {
        $kernel = 0;
    }
}

if ( $kernel == 1 ) {
    notify $cnt, "kernel: linux";
}
