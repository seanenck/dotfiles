#!/usr/bin/perl
use strict;
use warnings;

my $apps = "firefox kitty pavucontrol mumble keepassxc vlc";

if (!@ARGV) {
    print "$apps";
    exit 0;
}

my $cmd = shift @ARGV;
if ( $cmd ne "wofi" ) {
    print "unknown command\n";
    exit 0;
}
system("echo $apps | tr ' ' '\\n' | sed 's/firefox/firefox-developer-edition/g' | wofi --show dmenu -i --style=\$HOME/.config/wofi/style.css | \${SHELL:-'/bin/sh'}");
