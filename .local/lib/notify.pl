#!/usr/bin/perl
use warnings;
use strict;

my $home  = $ENV{"HOME"};
my $cache = "$home/.local/tmp/notify/";
my $lib   = "$home/.local/lib/";
my $daily = `date +%Y%m%d%p`;
chomp $daily;
$daily = "${cache}$daily";
my @dirs = ( "$home/.git", "$home/.local/private/.git" );

for ("workspace") {
    my $found = `find $home/$_/ -maxdepth 3 -type d -name ".git" | tr '\n' ' '`;
    chomp $found;
    push @dirs, split( / /, $found );
}

my $id = 500;

sub notify {
    $id += 1;
    my $cat = shift @_;
    if (@_) {
        my $text = join( "\n└ ", @_ );
        system("dunstify -r $id -t 20000 '$cat:\n└ $text'");
    }
    else {
        system("dunstify -C $id");
    }
}

my @git;
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
        push @git, "$dname [$count]";
    }
}

notify "git", @git;

my @mail;

my %mail_count;
for (`bash ${lib}mail_client.sh new | grep '^mail:' | cut -d ':' -f 2-`) {
    chomp;
    my $dir = $_;
    if ( !exists( $mail_count{$dir} ) ) {
        $mail_count{$dir} = 0;
    }
    $mail_count{$dir} += 1;
}

for ( keys %mail_count ) {
    my $count = $mail_count{$_};
    push @mail, "$_ [$count]";
}

notify "mail", @mail;

my @kernel;
if ( `uname -r | sed "s/-arch/.arch/g"` ne
    `pacman -Qi linux | grep Version | cut -d ":" -f 2 | sed "s/ //g"` )
{
    push @kernel, "old kernel loaded";
}

notify "kernel", @kernel;

my @workspaces;
for my $desktop (`wmctrl -d | grep -v "\*" | cut -d ' ' -f 1`) {
    chomp $desktop;
    if ( $desktop eq "" ) {
        next;
    }
    my $workspace =
`wmctrl -l | cut -d ' ' -f 2- | sed 's/^\\s*//g' | grep '^$desktop ' | wc -l`
      + 0;
    if ( $workspace > 0 ) {
        my $number = $desktop + 1;
        push @workspaces, "W$number [$workspace]";
    }
}

notify "workspaces", @workspaces;

if ( !-e $daily ) {
    system("mkdir -p $cache") if !-d $cache;
    system("find $cache -type f -mtime +1 -delete");
    if ( -e $ENV{"IS_ONLINE"} ) {
        my @out;
        my $success     = 0;
        my $out_of_date = `perl ${lib}aem.pl flagged 2>&1`;
        $success = 1;
        if ($out_of_date) {
            if ( $out_of_date =~ m/out-of-date/ ) {
                my @parts = split( "\n", $out_of_date );
                for my $part (@parts) {
                    chomp $part;
                    if ($part) {
                        $part =~ s/out-of-date://g;
                        push @out, $part;
                    }
                }
            }
            else {
                $success = 0;
                push @out, "failed out-of-date check";
            }
        }
        notify "out-of-date", @out;
        if ( $success == 1 ) {
            system("touch $daily");
        }
    }
}
