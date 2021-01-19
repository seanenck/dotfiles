#!/usr/bin/perl
use strict;
use warnings;

my $home = $ENV{"HOME"};
my $dir  = "$home/store/config/notebook/";
my $dest = "$home/.cache/wiki/";
my $hash = "${dest}hash";
my $prev = "${hash}.prev";
my $date = `date +%Y-%m-%dT%H%M:%S`;
$dest = "${dest}notebook/";

if (@ARGV) {
    my $cmd = shift @ARGV;
    if ( $cmd eq "ls" ) {
        system("find $dir -type f -name '*.md' | sed 's#$dir##g'");
    }
    elsif ( $cmd eq "edit" ) {
        my $files = "";
        for (@ARGV) {
            my $f = "${dir}$_";
            if ( -e $f ) {
                $files = "$files $f";
            }
        }
        if ( !$files ) {
            die "no files found";
        }
        system("vim $files");
    }
    else {
        die "unknown command: $cmd";
    }
    exit 0;
}

system("find $dir -type f -exec md5sum {} \\; > $hash");
if ( -e $prev ) {
    exit 0 if ( system("diff -u $prev $hash") == 0 );
}

system("rm -rf $dest");
system("mkdir $dest");
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
    my $short = `echo $page | sed 's#$dest##g;s#\\.html##g'`;
    chomp $short;
    $shorts{$page} = $short;
}

sub build {
    my $page  = shift @_;
    my $links = "";
    for my $short ( sort keys %shorts ) {
        my $disp = $shorts{$short};
        $disp = "[$disp]";
        if ( $short eq $page ) {
            $links = "$links $disp";
        }
        else {
            $links = "$links <a href='$short'>$disp</a>";
        }
    }
    my $dir_name = `dirname $page`;
    chomp $dir_name;
    system("mkdir -p $dir_name");
    system(
"echo '<html><body><div>$links<hr /></div><div>' > $page"
    );
    if ( exists( $pages{$page} ) ) {
        my $file = $pages{$page};
        system("python -m markdown -x fenced_code $file >> $page");
    }
    else {
        system("echo '<h4>Wiki</h4>' >> $page");
    }
    system("echo '</div><div><hr /><small>$date</small></div></body></html>' >> $page");
}

build $index_page;
for my $page ( sort keys %pages ) {
    build $page;
}
