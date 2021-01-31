#!/usr/bin/perl
use warnings;
use strict;

my $home  = $ENV{"HOME"};
my $cache = "$home/.local/tmp/bar/";
my $lib   = "$home/.local/lib/";
system("mkdir -p $cache") if ! -d $cache;

die "no args given" if !@ARGV;

my $cmd = shift @ARGV;

if ( $cmd eq "mail" ) {
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
    @mail = sort @mail;
    print join(", ", @mail);
}
elsif ( $cmd eq "apps" ) {
    my $apps = `perl $lib/apps.pl list`;
    chomp $apps;
    my @list;
    for my $app ( split(" ", $apps) ) {
        chomp $app;
        if ( !$app ) {
            next;
        }
        my $cnt = `pidof $app | tr ' ' '\\n' | wc -l` + 0;
        if ( $app eq "firefox" and $cnt > 0 ) {
            $cnt = 1;
        }
        if ( $cnt > 0 ) {
            push @list, "${app}[$cnt]";
        }
    }
    @list = sort @list;
    print join(" ", @list);
}
elsif ( $cmd eq "sync" ) {
    my $daily = `date +%Y%m%d%p`;
    chomp $daily;
    $daily = "$cache$daily.daily";
    if ( -e $daily ) {
        system("cat $daily");
        exit 0;
    }
    if ( -e $ENV{"IS_ONLINE"} ) {
        my $data = "";
        my @out;
        my $success     = 0;
        my $out_of_date = `perl ${lib}aem.pl flagged 2>&1`;
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
                push @out, "failed out-of-date check";
            }
        }
        my $tag =
`curl -s https://hub.darcs.net/raichoo/hikari/changes | grep TAG | head -n 1 | cut -d '>' -f 2 | cut -d '<' -f 1 | cut -d ' ' -f 2`;
        chomp $tag;
        my $vers =
`pacman -Ss hikari | head -n 1 | cut -d " " -f 2 | cut -d "-" -f 1`;
        chomp $vers;
        if ( $tag ne $vers ) {
            push @out, "hikari version change";
        }
        $data = join(" ", @out);
        open(my $fh, ">", $daily);
        print $fh join(" ", $data);
        close($fh);
    }
}
