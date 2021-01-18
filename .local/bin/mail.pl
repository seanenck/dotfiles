#!/usr/bin/perl
use strict;
use warnings;

my $home         = $ENV{"HOME"};
my $local    = "$home/.local/bin/";
my $script          = "perl ${local}mail.pl";
my $sys          = "${local}sys";
my $imap  = "$home/store/imap";

if (@ARGV) {
    my $command = $ARGV[0];
    if ( $command eq "poll" ) { 
        exit if ( system("$sys online") != 0 );
        my $mail_dir = "/tmp/mail";
        mkdir $mail_dir if !-d $mail_dir;
        my $time = `date +%Y-%m-%d-%H-`;
        chomp $time;
        $time .= `date +%M` >= 30 ? "30" : "00";
        my $mail_file = $mail_dir . "/$time";
        my $mutt      = $mail_dir . "/mutt";

        if ( system("pgrep -x mutt > /dev/null") == 0 ) {
            system("touch $mutt");
            exit;
        }
        if ( -e $mutt ) {
            system("rm -f $mutt $mail_file");
        }

        exit if -e "$mail_file";
        system("$script sync");
        system("touch $mail_file");
    }
    elsif ( $command eq "sync" ) {
        if ( -d $imap ) {
            exit 0 if system("pgrep -x mbsync > /dev/null") == 0;
            system("notify-send -t 5000 'syncing mail'");
            for ( ( "mbsync -a", "notmuch new" ) ) {
                system("$_ | systemd-cat -t 'mbsync'");
            }
        }
    }
    else {
        die "unknown command";
    }
    exit 0;
}

while (1) {
    system("$script poll");
    sleep 15;
}
