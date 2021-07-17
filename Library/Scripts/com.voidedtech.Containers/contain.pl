#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

my $release = "3.14.0";
my $version = join(".", split(".", $release));

my $directory = "/Users/enck/Containers/";
my $current = "${directory}$release/";

my $iso = "https://dl-cdn.alpinelinux.org/alpine/v$version/releases/aarch64/alpine-standard-$release-aarch64.iso";

system("mkdir -p $directory");
my $iso_file = "$current/$release.iso";
if ( ! -d $current ) {
    system("mkdir -p $current");
    system("curl '$iso' > $current/$iso_file");
}

#vftool -m 2048 -k vmlinuz-lts -i initramfs-lts -d alpine-standard-3.14.0-aarch64.iso -a "console=hvc0 modules=loop,squashfs,virtio" -d
