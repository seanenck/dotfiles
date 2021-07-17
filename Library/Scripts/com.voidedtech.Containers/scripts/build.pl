#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

my $release = "3.14.0";
my $size    = "1G";

my $version = `echo '$release' | rev | cut -d '.' -f 2- | rev`;
chomp $version;

my $directory = $ENV{"CONTAINER_BASE"};

my $current = "${directory}releases/$release/";

my $iso =
"https://dl-cdn.alpinelinux.org/alpine/v$version/releases/aarch64/alpine-standard-$release-aarch64.iso";

system("mkdir -p $directory");
my $iso_file = "$current/$release.iso";
if ( !-d $current ) {
    print "downloading release $release\n";
    system("mkdir -p $current");
    print "$iso\n";
    die "unable to download iso" if system("curl '$iso' > $iso_file") != 0;
    my $unpack = "${current}unpack";
    system("mkdir -p $unpack");
    die "unable to unpack " if system("isox $iso_file $unpack") != 0;
    system("cp $unpack/boot/vmlinuz_lts. $unpack/vmlinuz-lts.gz");
    system("cp $unpack/boot/initramfs_lts. $unpack/initramfs-lts");
    die "unable to gzip vmlinuz" if system("cd $unpack && gzip -d *.gz") != 0;
    system("mv $unpack/*-lts $current");
    system("rm -rf $unpack");
}

my $count = 2;
my $made  = 0;
while ( $count <= 254 ) {
    my $path = "${directory}192.168.64.$count/";
    if ( -d $path ) {
        $count = $count + 1;
        next;
    }
    print "creating $path\n";
    system("mkdir -p $path");
    system("cp $iso_file ${path}boot.iso");
    system("cp ${current}*-lts ${path}");
    system("mkdir -p ${path}store");
    die "unable to make store"
      if system(
"cd $path && hdiutil create storage -size $size -srcfolder store/ -fs exFAT -format UDRW"
      ) != 0;
    $made = 1;
    last;
}

die "unable to make a new container" if $made == 0;
