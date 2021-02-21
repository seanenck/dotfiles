#!/usr/bin/perl
use warnings;
use strict;

my $disp = $ENV{"WAYLAND_DISPLAY"};
if ( !$disp ) {
    exit 0;
}

my $home  = $ENV{"HOME"};
my $cache = "$home/.local/tmp/notify/";
my $lib   = "$home/.env/thin/lib/";
my @dirs  = ( "$home/.git", "$home/.local/private/.git" );
system("mkdir -p $cache") if !-d $cache;

for ("workspace") {
    my $found = `find $home/$_/ -maxdepth 3 -type d -name ".git" | tr '\n' ' '`;
    chomp $found;
    push @dirs, split( / /, $found );
}

my $last = "${cache}notices.category";
my $prev = "$last.prev";
open( my $fh, ">", $last );

sub notify {
    my $cat = shift @_;
    if (@_) {
        my $text = join( "\n└ ", @_ );
        print $fh "$cat:\n└ $text\n";
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
for (`bash ${lib}mailclient.sh new | grep '^mail:' | cut -d ':' -f 2-`) {
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

close($fh);

chomp(my $current_notifications = `makoctl list | tr ':' '\n' | grep app-name | wc -l`);
$current_notifications = $current_notifications + 0;
if ( $current_notifications > 5 ) {
    system("makoctl dismiss --all");
}

my $listing = `makoctl list | tr '\\n' ' ' | sed 's/\\s*//g'`;
chomp $listing;
my $force = 0;

if ( $listing eq '{"type":"aa{sv}","data":[[]]}' ) {
    if ( -s $last ) {
        $force = 1;
    }
}

if ( $force == 0 ) {
    if ( -e $prev ) {
        if ( system("diff -u $prev $last > /dev/null") == 0 ) {
            exit 0;
        }
    }
}

system("cp $last $prev");
system("makoctl dismiss --all");
if ( -s $last ) {
    system( 'notify-send "$(cat ' . $last . ' | grep -v \"^$\")"' );
}
