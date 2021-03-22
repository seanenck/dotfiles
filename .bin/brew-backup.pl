#!/usr/bin/perl
use strict;
use warnings;

my %deps;
my %installed;

for my $pkg (`brew list -1`) {
    chomp $pkg;
    next if !$pkg;
    $installed{$pkg} = 1;
    for my $dep (`brew deps -1 $pkg`) {
        chomp $dep;
        next if !$dep;
        $deps{$dep} = 1;
    }
}

for (keys %installed) {
    if (exists($deps{$_})) {
        next;
    }
    my $type = "formula";
    if (system("brew list --casks $_ > /dev/null 2>&1") == 0) {
        $type = "cask";
    }
    print "$type: $_\n";
}
