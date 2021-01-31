#!/usr/bin/perl
use strict;
use warnings;

my $apps = "firefox kitty pavucontrol mumble keepassxc vlc";

my %local;
for (`find $ENV{"HOME"}/.local/apps -type l`) {
    chomp;
    if ($_) {
        my $name = `basename $_`;
        chomp $name;
        $local{"$name"} = $_;
        $apps = "$apps $name";
    }
}

my $count  = `echo $apps | tr ' ' '\\n' | wc -l` + 0;
my $chosen =
`echo $apps | tr ' ' '\\n' | sed 's/firefox/firefox-developer-edition/g' | wofi --show dmenu -W 15% -L $count -i --style=\$HOME/.config/wofi/style.css`;
chomp $chosen;
if ( !$chosen ) {
    exit 0;
}

if ( exists( $local{$chosen} ) ) {
    system("bash $local{$chosen}");
    exit 0;
}

system("$chosen");
