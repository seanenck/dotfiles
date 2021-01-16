#!/usr/bin/perl
use strict;
use warnings;

if ( !@ARGV ) {
    die "subcommand required";
}

my $command = shift @ARGV;
my $src     = "/opt/chroots/";
my $dev     = "${src}dev";
my $build   = "${src}builds";
my $drop    = "/var/cache/voidedtech/pacman/";
my $server  = "voidedtech.com";
my $ssh     = "ssh  $server -- ";

sub header {
    print "\n=========\n";
    print shift @_;
    print "\n=========\n\n";
}

if ( $command eq "makepkg" ) {
    die "no PKGBUILD" if !-e "PKGBUILD";

    for ( ( "log", "tar.zst" ) ) {
        system("rm -f *.$_");
    }

    my $makepkg = "/tmp/makepkg.conf";
    system("cat /etc/makepkg.conf \$HOME/.makepkg.conf > $makepkg");
    system("sudo install -Dm644 $makepkg $build/root/etc/makepkg.conf");
    unlink $makepkg;

    die "packaging failed"
      if system("makechrootpkg -c -n -d /var/cache/pacman/pkg -r $build") != 0;
}
elsif ( $command eq "sync" or $command eq "run" ) {
    my $run = "pacman -Syyu";
    my $chroot  = 1;
    if ( $command eq "run" ) {
        if (!@ARGV) {
            die "no run commands given";
        }
        $chroot  = 0;
        $run = join( " ", @ARGV );
    }

    if ( $chroot == 1 ) {
        header "builds";
        system("arch-nspawn $build/root $run");
        print "\n";
    }

    if ( !-d $dev ) {
        exit 0;
    }

    header "dev";
    system("sudo schroot -c source:dev -- $run");
}
elsif ( $command eq "repoadd" ) {
    die "no package" if ( !@ARGV );
    for my $package (@ARGV) {
        die "no package exists: $package" if !-e $package;

        die "not a valid package" if ( not $package =~ m/\.tar\./ );
        my $basename = `echo $package | rev | cut -d '-' -f 4- | rev`;
        chomp $basename;

        system("$ssh find $drop -name '$basename-\*' -delete");
        system("scp $package $server:$drop");
        system("$ssh 'cd $drop; repo-add localdev.db.tar.gz $package'");
    }
}
elsif ( $command eq "schroot" ) {
    die "must NOT run as root" if ( $> == 0 );
    if ( -d $dev ) {
        system("mkdir -p /dev/shm/schroot/overlay");
        system("schroot -c chroot:dev");
        exit 0;
    }
    header "building ($dev)";
    system("sudo mkdir -p $dev");
    system("sudo pacstrap -c -M $dev/ base-devel vim sudo git voidedskel openssh go go-bindata golint-git rustup ripgrep man man-pages vim-nerdtree vimsym vim-airline bash-completion");
}
elsif ( $command eq "help" ) {
    print "run sync makepkg repoadd schroot";
}
else {
    die "unknown command $command";
}
