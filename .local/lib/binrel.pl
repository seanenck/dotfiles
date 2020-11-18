#!/usr/bin/perl
use strict;
use warnings;
use autodie;

my $mode;
die "no mode given" if ( !@ARGV );
$mode = shift @ARGV;
my $path = $ENV{"HOME"} . "/store/binaries/$mode/";
die "invalid mode" if !-d $path;

my @targets = ("voidedtech.com");
if ( $mode eq "pacman" ) {
    push @targets, "shelf";
    push @targets, "novel";
}
else {
    open my $fh, ">", "${path}index.html";
    print $fh "<!doctype html>
<html lang=\"en\">
<head>
	<meta charset=\"utf-8\"/>
    <link href=\"/main.css\" rel=\"stylesheet\" type=\"text/css\" />
	<title>Binaries</title>
</head>
<body>
<div class=\"header-text\"><div id=\"header\">
        <p>Binaries</p></div><p>Simple hosted pre-built binaries of personal projects</p>
<hr></div>
<div id=\"main\">
<pre>
Instructions

1. download &lt;file&gt;.(rpm|deb)
2. compare sha256 hash
3. install using package manager
<pre>
<hr /><pre>";
    for (`ls $path/* | grep -v html`) {
        chomp;
        my $hash     = `sha256sum $_ | cut -d " " -f 1`;
        my $basename = `basename $_`;
        chomp $hash;
        chomp $basename;
        print $fh "<code>$hash</code> <a href='$basename'>$basename</a><br />";
    }
    my $date = `date +%Y-%m-%d`;
    chomp $date;
    print $fh "</pre><small>last updated: $date</small></div>
<div class=\"footer-text\"><hr />
    <a href=\"/\">home</a>
</div>
</body>
</html>";
}

for (@targets) {
    system("rsync -acv --delete-after $path $_:/opt/$mode/");
}
