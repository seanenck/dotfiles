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
my $drop    = "/opt/local/";
my $server  = "voidedtech.com";
my $ssh     = "ssh  $server -- ";
my $build_root = "$build/root";
my $gpg_key = "031E9E4B09CFD8D3F0ED35025109CDF607B5BB04";

sub header {
    print "\n=========\n";
    print shift @_;
    print "\n=========\n\n";
}

if ( $command eq "makepkg" ) {
    die "no PKGBUILD" if !-e "PKGBUILD";

    for ( ( "log", "tar.zst", "sig" ) ) {
        system("rm -f *.$_");
    }

    my $makepkg = "/tmp/makepkg.conf";
    system("cat /etc/makepkg.conf \$HOME/.makepkg.conf > $makepkg");
    system("sudo install -Dm644 $makepkg $build_root/etc/makepkg.conf");
    unlink $makepkg;

    die "packaging failed"
      if system("makechrootpkg -c -n -d /var/cache/pacman/pkg -r $build") != 0;
    my $packaged = 0;
    for my $package (`ls *.tar.zst`) {
        chomp $package;
        if ( $package ) {
            print "signing $package\n";
            die "signing failed: $package" if system("gpg --detach-sign --use-agent $package") != 0;
            $packaged += 1;
        }
    }
    die "nothing packaged" if $packaged == 0;
    print " -> $packaged packages built and signed\n";
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
        system("arch-nspawn $build_root $run");
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
        my $sig = "$package.sig";
        die "no signature: $package" if !-e $sig;

        die "not a valid package" if ( not $package =~ m/\.tar\./ );
        my $basename = `echo $package | rev | cut -d '-' -f 4- | rev`;
        chomp $basename;

        if ( system("$ssh test -e $drop$package") == 0 ) {
            die "$package already deployed";
        }
        system("$ssh find $drop -name '$basename-\*' -delete");
        system("scp $package $sig $server:$drop");
        system("$ssh 'cd $drop; repo-add local.db.tar.gz $package'");
    }
}
elsif ( $command eq "buildchroot" ) {
    die "build chroot exists" if -d $build;
    die "must NOT run as root" if ( $> == 0 );
    system("sudo mkdir -p $build");
    system("sudo mkarchroot $build_root base-devel");
    system("sudo cp /etc/pacman.conf $build_root/etc/pacman.conf");
    system("sudo arch-nspawn pacman-key --recv-key $gpg_key");
    system("sudo arch-nspawn pacman-key --lsign-key $gpg_key");

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
    system("sudo pacstrap -c -M $dev/ base-devel baseskel go go-bindata golint-git rustup");
    system("sudo schroot -c source:dev -- pacman-key --lsign-key $gpg_key");
}
elsif ( $command eq "help" ) {
    print "run sync makepkg repoadd schroot buildchroot";
}
else {
    die "unknown command $command";
}
