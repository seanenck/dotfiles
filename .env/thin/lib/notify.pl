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
system("mkdir -p $cache") if !-d $cache;

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

close($fh);

chomp( my $current_notifications =
      `makoctl list | tr ':' '\n' | grep app-name | wc -l` );
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
