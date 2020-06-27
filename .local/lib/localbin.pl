#!/usr/bin/perl
use strict;
use warnings;
use autodie;
use File::Temp qw/ tempdir /;
use File::Basename;

die "package required" if (!@ARGV);
my $package = shift @ARGV;
die "not a valid package" unless ($package =~ /\.tar\.xz$/);

my $tmpdir = tempdir( CLEANUP => 1 );

die "unable to unpack" if system("tar xf $package -C $tmpdir") != 0;

my $files = `find $tmpdir -type f -name "[!.]*" | tr '\\n' ' '`;
chomp $files;

die "no files found" if (!$files);

my @installs;

for my $fname (split(/ /, $files)) {
    my ($filebase) = fileparse($fname);
    $fname =~ s#$tmpdir/usr/bin/##g; 
    unless ($fname eq $filebase) {
        print "WARN: ignoring non-binary: $fname\n";
        next;
    }
    push @installs, "usr/bin/" . $fname;
}

die "no files to install" if (@installs == 0);

my ($base) = fileparse($package);
$base =~ s/\-x86_64\.pkg\.tar\.xz//;
my $target = "/home/enck/store/managed/binaries/" . $base . ".tar.gz";
my ($archive) = fileparse($target);
unlink $target if (-e $target);

my $configure = "configure";
my $script = '#!/bin/bash';
my @archive;

for my $op (("install", "clean")) {
    $script .= "\n_$op() {\n";
    for my $fname (@installs) {
        if ($op eq "install") {
            push @archive, $fname;
            my ($name) = fileparse($fname);
            $script .= "    install -Dm755 $fname /usr/local/bin/$name\n";
        } else {
            $script .= "    rm $fname\n";
        }
    }
    if ($op eq "clean") {
        $script .= "    rmdir usr/bin\n";
        $script .= "    rmdir usr/\n";
        $script .= "    rm $configure\n";
    } else {
        $script .= "    _clean\n";
    }
    $script .= "}\n";
}

$script .= '
_stop() {
    echo "$1"
    _clean
    exit 1
}

for f in ' . $archive . " " . $configure . '; do
    if [ ! -e $f ]; then
        echo "must be run from the unpacked directory (missing: $f)"
        exit 1
    fi
done

if [ $UID -ne 0 ]; then
    sudo ./configure
    exit $?
fi

read -p "confirm installation (Y/n)? " confirm
if [[ $confirm != "Y" ]]; then
    _stop "operation stopped"
fi
_install
';

push @archive, $configure;
$configure = $tmpdir . '/' . $configure;
open (my $fh, ">", $configure);
print $fh $script;
chmod 0755, $configure;

die "unable to archive" if system("cd $tmpdir && tar czvf $target " . join(" ", @archive));

print "INFO: wrote $target\n";
