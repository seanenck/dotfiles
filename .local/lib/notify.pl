#!/usr/bin/perl
use warnings;
use strict;

my $disp = $ENV{"WAYLAND_DISPLAY"};
if ( !$disp ) {
    exit 0;
}

my $home  = $ENV{"HOME"};
my $cache = "$home/.local/tmp/notify/";
my $lib   = "$home/.local/lib/";
my $daily = `date +%Y%m%d%p`;
chomp $daily;
$daily = "${cache}$daily";
my @dirs = ( "$home/.git", "$home/.local/private/.git" );
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

if ( !-e $daily ) {
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

close($fh);
if ( -e $prev ) {
    if ( system("diff -u $prev $last > /dev/null") == 0 ) {
        exit 0;
    }
}
system("cp $last $prev");
system("makoctl dismiss --all");
if ( -s $last ) {
    my $notices = `cat $last`;
    chomp $notices;
    system("dunstify -r 1000 -t 20000 '$notices'");
}
