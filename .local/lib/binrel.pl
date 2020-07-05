#!/usr/bin/perl
use strict;
use warnings;
use autodie;

my $mode;
die "no mode given" if ( !@ARGV );
$mode = shift @ARGV;
my $path = $ENV{"HOME"} . "/store/managed/$mode/";
die "invalid mode" if !-d $path;

my @targets = ("voidedtech.com");
if ( $mode eq "pacman" ) {
    push @targets, "core";
}
else {
    for my $bname (
`find $path -type f -exec basename {} \\; | grep -v "index.html" | rev | cut -d "-" -f 3- | rev | sort -u`
      )
    {
        chomp $bname;
        my $first = 1;
        for (`ls $path | grep "^$bname" | sort -r`) {
            chomp;
            if ( $first == 1 ) {
                $first = 0;
                next;
            }
            print "purge: $_ (Y/n)? ";
            my $line = <STDIN>;
            $line = lc $line;
            chomp $line;
            if ( $line eq "n" ) {
                next;
            }
            system("rm -f $path/$_");
        }
    }
    open my $fh, ">", "${path}index.html";
    print $fh "<html>
<body>
<pre>
binaries
===

Simple hosted pre-built binaries of personal projects.

1. download &lt;file&gt;.tar.gz
2. compare sha256 hash
3. tar xf &lt;file&gt;.tar.gz
4. ./configure
5. follow the prompts
<pre>
<hr /><pre>";
    for (`ls $path*.tar.gz`) {
        chomp;
        my $hash     = `sha256sum $_ | cut -d " " -f 1`;
        my $basename = `basename $_`;
        chomp $hash;
        chomp $basename;
        print $fh "<code>$hash</code> <a href='$basename'>$basename</a><br />";
    }
    my $date = `date +%Y-%m-%d`;
    chomp $date;
    print $fh "</pre><small>last updated: $date</small></body></html>";
}

for (@targets) {
    system("rsync -acv --delete-after $path $_:/opt/$mode/");
}
