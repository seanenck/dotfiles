#!/usr/bin/perl
use strict;
use warnings;

my $home      = $ENV{"HOME"};
my $mutt_home = "$home/.mutt/";
my $script    = "perl ${mutt_home}mail.pl";
my $imap      = "$home/.mutt/maildir/fastmail/";
my $mutt      = "$home/store/active/hosted/files/mutt/";

my $mutt_session = "mutt";
my $start_mutt   = "/tmp/.startmutt";

if (@ARGV) {
    my $command = $ARGV[0];
    if ( $command eq "poll" ) {
        my $mail_dir = "/tmp/muttsync";
        mkdir $mail_dir if !-d $mail_dir;
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
        system("$script sync");
        system("touch $mail_file");
        system("find $mutt -type f -mmin +60 -delete");
    }
    elsif ( $command eq "sync" ) {
        if ( -d $imap ) {
            exit 0 if system("pgrep -x mbsync > /dev/null") == 0;
            for ( ( "mbsync -a", "notmuch new" ) ) {
                system("$_ | systemd-cat -t 'mbsync'");
            }
        }
    }
    elsif ( $command eq "mutt" ) {
        if ( system("tmux has-session -t $mutt_session > /dev/null 2>&1") != 0 )
        {
            system("touch $start_mutt");
            while (1) {
                if ( -e $start_mutt ) {
                    next;
                }
                last;
            }
        }
        system("tmux attach -t $mutt_session");
    }
    elsif ( $command eq "daemon" ) {
        system("$script 2>&1 | systemd-cat -t muttmail");
        exit 0;
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

my $count = 0;
while (1) {
    if ( -e $start_mutt ) {
        system("pkill mutt");
        system(
"tmux new-session -d -s $mutt_session -- /usr/bin/mutt -F $home/.mutt/fastmail.muttrc"
        );
        unlink $start_mutt;
    }

    system("find $mutt -type f -exec chmod 644 {} \\;");
    if ( $count >= 60 ) {
        system("$script poll");
        $count = 0;
    }
    $count += 1;
    sleep 1;
}
