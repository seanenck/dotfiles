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
my $server     = $ENV{"REMOTE_SERVER"};
my $ssh        = "ssh  $server -- ";
my $build_root = "$build/root";
my $home       = $ENV{"HOME"};
my $aem_base   = "$home/.local/var/aem/";
my $flag_base  = "${aem_base}flagged";
my $gpg_key    = "031E9E4B09CFD8D3F0ED35025109CDF607B5BB04";
my $flag_log   = "${flag_base}.log";
my $self       = "perl $home/.local/lib/aem.pl";

die "must NOT run as root" if ( $> == 0 );

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

    my $makepkg = "$home/.local/tmp/makepkg.conf";
    system("cat /etc/makepkg.conf $home/.makepkg.conf > $makepkg");
    system("sudo install -Dm644 $makepkg $build_root/etc/makepkg.conf");
    unlink $makepkg;

    die "packaging failed"
      if system("makechrootpkg -c -n -d /var/cache/pacman/pkg -r $build") != 0;
    my $packaged = 0;
    for my $package (`ls *.tar.zst`) {
        chomp $package;
        if ($package) {
            print "signing $package\n";
            die "signing failed: $package"
              if system("$self detach-sign $package") != 0;
            $packaged += 1;
        }
    }
    die "nothing packaged" if $packaged == 0;
    print " -> $packaged packages built and signed\n";
}
elsif ( $command eq "detach-sign" ) {
    my $input = shift @ARGV;
    die "no input given" if !-e $input;
    if ( system("gpg --detach-sign --use-agent $input") != 0 ) {
        print "signing failed: $input\n";
        exit 1;
    }
}
elsif ( $command eq "sync" or $command eq "run" ) {
    if ( $command ne "run" ) {
        header "files";
        system("sudo pacman -Fy");
    }
    my $run    = "pacman -Syyu";
    my $chroot = 1;
    if ( $command eq "run" ) {
        if ( !@ARGV ) {
            die "no run commands given";
        }
        $chroot = 0;
        $run    = join( " ", @ARGV );
    }

    if ( $chroot == 1 ) {
        header "builds";
        system("sudo arch-nspawn $build_root $run");
        print "\n";
    }

    if ( !-d $dev ) {
        exit 0;
    }

    header "dev";
    system("sudo schroot -c source:dev -- $run");
}
elsif ( $command eq "repo-add" ) {
    my $repo = shift @ARGV;
    die "no repo given" if !$repo;
    my $repo_name = `echo $repo | cut -d "." -f -1`;
    chomp $repo_name;
    my $drop = "$root_repo$repo_name/";
    die "invalid repository" if ( system("$ssh test -d $drop") != 0 );
    die "no package"         if ( !@ARGV );
    for my $package (@ARGV) {
        die "no package exists: $package" if !-e $package;
        my $sig = "$package.sig";
        die "no signature: $package" if !-e $sig;

        die "not a valid package" if ( not $package =~ m/\.tar\./ );
        my $basename = `echo $package | rev | cut -d '-' -f 4- | rev`;
        chomp $basename;
        my $find     = "$ssh find $drop -name '$basename-\*'";
        my $existing = `$find -print`;
        chomp $existing;
        if ( !$existing ) {
            print "deploy NEW $package to $repo? (y/N)\n";
            my $yes = <STDIN>;
            chomp $yes;
            $yes = lc $yes;
            if ( $yes ne "y" ) {
                exit 0;
            }
        }
        die "$package already deployed"
          if ( system("$ssh test -e $drop$package") == 0 );
        system("$find -delete");
        system("scp $package $sig $server:$drop");
        system("$ssh 'cd $drop; repo-add $repo $package'");
    }
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
elsif ( $command eq "schroot" ) {
    die "schroot not defined" if !-d $dev;
    system("mkdir -p /dev/shm/schroot/overlay");
    system("schroot -c chroot:dev");
    exit 0;
}
elsif ( $command eq "flagged" ) {
    system("mkdir -p $flag_base") if !-d $flag_base;
    my $redir    = ">> $flag_log 2>&1";
    my $tmp_flag = `mktemp`;
    chomp $tmp_flag;
    system("date +%Y-%m-%dT%H:%M:%S $redir");
    system("cat $flag_log | tail -n 1000 > $tmp_flag");
    system("mv $tmp_flag $flag_log");
    my %remotes;
    my %filters;
    $remotes{"baseskel"}     = "git://cgit.voidedtech.com/skel";
    $remotes{"devskel"}      = "git://cgit.voidedtech.com/skel";
    $remotes{"serverskel"}   = "git://cgit.voidedtech.com/skel";
    $remotes{"corescripts"}  = "git://cgit.voidedtech.com/corescripts";
    $remotes{"sysmon"}       = "git://cgit.voidedtech.com/sysmon";
    $remotes{"voidedtech"}   = "git://cgit.voidedtech.com/whoami";
    $remotes{"kxstitch-git"} = "https://github.com/KDE/kxstitch";
    $filters{"voidedtech"}   = "src/";

    for my $base ( ( "base", "dev", "server" ) ) {
        $filters{"${base}skel"} = "$base/";
    }

    my @notices;

    my %done;
    for my $package (`pacman -Sl vpr | cut -d " " -f 2`) {
        chomp $package;
        next if !$package;
        if ( !exists $remotes{$package} ) {
            next;
        }
        system("echo $package $redir");
        my $remote      = $remotes{$package};
        my @remote_obj  = split( "/", $remote );
        my $remote_base = "$flag_base/$remote_obj[-1]";
        if ( !-d $remote_base ) {
            die "unable to clone"
              if system("git clone --depth=1 $remote $remote_base $redir") != 0;
        }
        if ( !exists( $done{$remote_base} ) ) {
            for my $cmd ( ( "fetch", "pull" ) ) {
                die "git command $cmd failed for $package"
                  if system("git -C $remote_base $cmd $redir") != 0;
            }
            $done{$remote_base} = $remote_base;
        }
        my $filter = ".";
        if ( exists( $filters{$package} ) ) {
            $filter = $filters{$package};
        }
        my $date =
`git -C $remote_base log -1 --format=%cd --date=format:%Y%m%d.%H%M%S $filter`;
        chomp $date;
        my $vers =
`pacman -Ss $package | grep 'vpr/$package' | cut -d " " -f 2 | rev | cut -d "-" -f 2- | rev`;
        chomp $vers;
        die "unable to read package version for: $package" if !$vers;
        my $compare = $vers cmp $date;
        if ( $compare < 0 ) {
            push @notices, "out-of-date:$package";
        }
    }
    if (@notices) {
        my $notify = join( "\n", @notices );
        print $notify, "\n";
    }
}
elsif ( $command eq "help" ) {
    print "run sync makepkg repo-add schroot pacstrap flagged detach-sign";
}
else {
    die "unknown command $command";
}
