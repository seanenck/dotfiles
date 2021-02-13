#!/usr/bin/perl
use strict;
use warnings;

if ( !@ARGV ) {
    die "subcommand required";
}

my $command    = shift @ARGV;
my $src        = "/opt/chroots/";
my $dev        = "${src}dev";
my $build      = "${src}builds";
my $root_repo  = "/opt/archlinux/";
my $build_root = "$build/root";
my $home       = $ENV{"HOME"};
my $gpg_key    = "031E9E4B09CFD8D3F0ED35025109CDF607B5BB04";
my $self       = "perl $home/.local/lib/aem.pl";
my $pkg_cache  = "/var/cache/pacman/pkg/";

die "must NOT run as root" if ( $> == 0 );

sub header {
    print "\n=========\n";
    print shift @_;
    print "\n=========\n\n";
}

if ( $command eq "sync" ) {
    header "files";
    system("sudo pacman -Fy");
    my $run    = "pacman -Syyu";
    header "builds";
    system("sudo arch-nspawn $build_root $run");
    print "\n";

    if ( !-d $dev ) {
        exit 0;
    }

    header "dev";
    system("sudo schroot -c source:dev -- $run");
}
elsif ( $command eq "pacstrap" ) {
    if ( -d $build ) {
        print "build chroot exists\n";
    }
    else {
        system("sudo mkdir -p $build");
        system("sudo mkarchroot $build_root base-devel");
        system("sudo arch-nspawn $build_root pacman-key --recv-keys $gpg_key");
        system("sudo arch-nspawn $build_root pacman-key --lsign-key $gpg_key");
        system("sudo cp /etc/pacman.conf $build_root/etc/pacman.conf");
    }
    if ( -d $dev ) {
        print "dev schroot exists\n";
    }
    else {
        system("sudo mkdir -p $dev");
        system(
            "sudo pacstrap -c -M $dev/ base-devel go go-bindata revive rustup");
        for my $subcmd (
            (
                "pacman-key --recv-keys $gpg_key",
                "pacman-key --lsign-key $gpg_key",
                "locale-gen",
                "pacman -S baseskel"
            )
          )
        {
            system("sudo schroot -c source:dev -- $subcmd");
        }
    }
}
elsif ( $command eq "help" ) {
    print "sync pacstrap";
}
else {
    die "unknown command $command";
}
