#!/usr/bin/perl
use strict;
use warnings;

my $apps = "firefox kitty pavucontrol mumble keepassxc vlc";
if (@ARGV) {
    my $cmd = shift @ARGV;
    if ( $cmd eq "list" ) {
        print "$apps";
        exit 0;
    }
}

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

my $count = `echo $apps | tr ' ' '\\n' | wc -l` + 1;
my @app_list = split(" ", $apps);
my $app_text = join("\n", @app_list);
my $chosen =
`echo '$app_text' | sed 's/firefox/firefox-developer-edition/g' | wofi --show dmenu -W 20% -L $count -i --style=\$HOME/.config/wofi/style.css`;
chomp $chosen;
if ( !$chosen ) {
    exit 0;
}

if ( exists( $local{$chosen} ) ) {
    system("bash $local{$chosen}");
    exit 0;
}

for (@app_list) {
    if ($_ == $chosen) {
        system("$chosen");
        exit 0;
    }
}
