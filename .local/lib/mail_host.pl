#!/usr/bin/perl
use strict;
use warnings;

my $home      = $ENV{"HOME"};
my $mutt_home = "$home/.mutt/";
my $script    = "perl ${mutt_home}mail.pl";
my $imap      = "$home/.mutt/maildir/fastmail/";
my $mutt      = "$home/store/active/hosted/files/messages/";
my $mail_dir  = "$home/.local/tmp/muttsync";

if (@ARGV) {
    my $command = $ARGV[0];
    if ( $command eq "poll" ) {
        system("mkdir -p $mail_dir") if !-d $mail_dir;
        my $time = `date +%Y-%m-%d-%H-`;
        chomp $time;
        my $minute     = `date +%M` + 0;
        my $add_minute = "60";
        if ( $minute < 15 ) {
            $add_minute = "00";
        }
        elsif ( $minute < 30 ) {
            $add_minute = "30";
        }
        elsif ( $minute < 45 ) {
            $add_minute = "45";
        }
        $time = "$time$add_minute";
        my $mail_file = $mail_dir . "/$time";
        exit if -e "$mail_file";
        print "syncing mail via polling $time\n";
        system("$script sync");
        system("touch $mail_file");
        for ( ( $mutt, $mail_dir ) ) {
            system("find $_ -type f -mmin +60 -delete");
        }
    }
    elsif ( $command eq "sync" ) {
        if ( -d $imap ) {
            exit 0 if system("pgrep -x mbsync > /dev/null") == 0;
            for ( ( "mbsync -a", "notmuch new" ) ) {
                system("$_ | systemd-cat -t 'mbsync'");
            }
        }
    }
    else {
        die "unknown command";
    }
    my $output = "${mutt}new.txt";
    system("touch $output");
    system(
"find $imap -type f -path '*/new/*' | grep -v Trash | rev | cut -d '/' -f 3- | rev | sort | sed 's#$imap##g' > $output"
    );
    exit 0;
}

sub install {
    my $file = shift @_;
    my $dest = shift @_;
    my $mode = "644";
    if (@_) {
        $mode = shift @_;
    }
    system("install -Dm$mode $mutt_home$file ${dest}$file");
}

install "notmuch-config", "$home/.";
install "mail.vim",       "$home/.vim/ftplugin/";
install "mbsyncrc",       "$home/.";
install "msmtprc",        "$home/.", "600";

my $count    = 0;
my $saw_mutt = 0;
while (1) {
    system("find $mutt -type f -exec chmod 644 {} \\;");
    if ( $count >= 60 ) {
        system("$script poll");
        $count = 0;
    }
    my $has_mutt = system("pidof mutt >/dev/null");
    if ( $saw_mutt == 0 ) {
        if ( $has_mutt == 0 ) {
            print "mutt session started\n";
            $saw_mutt = 1;
        }
    }
    else {
        if ( $has_mutt != 0 ) {
            print "mutt session ended\n";
            system("$script sync");
            $saw_mutt = 0;
        }
    }
    $count += 1;
    sleep 1;
}
