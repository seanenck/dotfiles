#!/usr/bin/perl
use warnings;
use strict;
use File::Compare;
use File::Copy qw(move);

my $id       = 1000;
my $home     = $ENV{"HOME"};
my $messages = $ENV{"NOTIFY_MESSAGES"} . "/";
my @dirs     = ( $home . "/.git", "/etc/.git" );
for ( "workspace", "store" ) {
    my $found = `find $home/$_/ -maxdepth 3 -type d -name ".git" | tr '\n' ' '`;
    chomp $found;
    push @dirs, split( / /, $found );
}

my @alerts;
my @cats;

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
        push @cats,   "git";
        push @alerts, "git:$dname [$count]";
    }
}

my $imap = "$home/store/personal/imap/fastmail";
for (`find $imap -type d -name new -exec dirname {} \\; | grep -v Trash`) {
    chomp;
    my $count = `ls "$_/new/" | wc -l`;
    chomp $count;
    if ( $count > 0 ) {
        my $dname = $_;
        $dname =~ s#$imap/##g;
        push @cats,   "mail";
        push @alerts, "mail:'$dname [$count]'";
    }
}

system("backup status");
for (`pcm orphans`) {
    chomp;
    next if !$_;
    push @cats,   "orphan";
    push @alerts, "orphan:$_";
}

my $packages =
`du -h /var/cache/pacman/pkg | tr '\t' ' ' | cut -d " " -f 1 | grep "G" | sed "s/G//g" | cut -d "." -f 1`;
chomp $packages;
if ( $packages > 10 ) {
    push @cats,   "pkgcache";
    push @alerts, "pkgcache: $packages(G)";
}

my $kernel = 1;

for (("linux", "linux-lts")) {
    if ( `uname -r | sed "s/-arch/.arch/g"` ne
        `pacman -Qi $_ | grep Version | cut -d ":" -f 2 | sed "s/ //g"` ) {
        $kernel = 0;
    }
}

if ( $kernel == 1 ) {
    push @cats,   "kernel";
    push @alerts, "kernel:linux: kernel";
}

for my $file (`ls $messages`) {
    my $notice = `cat $messages$file`;
    chomp $notice;
    for my $line ( split( "\n", $notice ) ) {
        my @category = split( ":", $line );
        push @cats,   $category[0];
        push @alerts, $line;
    }
}

if ( @alerts == 0 ) {
    system("dunstify -C $id");
    exit 0;
}

my %tracked;
my $text  = "";
my $first = 1;
for my $cat (@cats) {
    if ( exists( $tracked{$cat} ) ) {
        next;
    }
    if ( $first == 1 ) {
        $first = 0;
    }
    else {
        $text = $text . "\n---\n\n";
    }
    $text = $text . "$cat:\n";
    my @remainders;
    for my $alert (@alerts) {
        if ( $alert =~ /^$cat:/ ) {
            my $msg = $alert =~ s/^$cat://g;
            $text = $text . "  $alert\n";
            next;
        }
        push @remainders, $alert;
    }
    @alerts = @remainders;
    $tracked{$cat} = 1;
}

system("dunstify -r $id -t 60000 '$text'");
