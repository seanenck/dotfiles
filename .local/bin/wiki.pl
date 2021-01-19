#!/usr/bin/perl
use strict;
use warnings;

my $home = $ENV{"HOME"};
my $dir  = "$home/store/config/notebook/";
my $dest = "$home/.cache/wiki/";
my $hash = "${dest}hash";
my $prev = "${hash}.prev";

system("find $dir -type f -exec md5sum {} \\; > $hash");
if ( -e $prev ) {
    exit 0 if ( system("diff -u $prev $hash") == 0 );
}

system("mv $hash $prev");
my @index;
my %pages;
for (`find $dir -type f -name "*.md"`) {
    chomp $_;
    my $name = $_;
    $name =~ s#$dir##g;
    $name =~ s#\.md$##g;
    push @index, $name;
    my $page = "${dest}$name.html";
    $pages{$page} = $_;
}

my $index_page = "${dest}index.html";
my %shorts;
$shorts{$index_page} = "index";
for my $page ( keys %pages ) {
    my $short = `echo $page | rev | cut -d '/' -f 1 | rev | cut -d '.' -f 1`;
    chomp $short;
    $shorts{$page} = $short;
}

sub build {
    my $page  = shift @_;
    my $links = "";
    for my $short ( sort keys %shorts ) {
        my $disp = $shorts{$short};
        if ( $short eq $page ) {
            $links = "$links $disp";
        }
        else {
            $links = "$links <a href='$short'>$disp</a>";
        }
    }
    system("echo '<html><body><div>$links<hr/>' > $page");
    if ( exists( $pages{$page} ) ) {
        my $file = $pages{$page};
        system("python -m markdown $file >> $page");
    }
    else {
        system("echo '<h4>Wiki</h4>' >> $page");
    }
    system("echo '</div></body></html>' >> $page");
}

build $index_page;
for my $page ( sort keys %pages ) {
    build $page;
}
