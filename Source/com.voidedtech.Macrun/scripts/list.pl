#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

my $dir       = $ENV{"MACRUN_STORE"};
my $ip_prefix = "192.168.64.";
my $cols      = `tput cols`;
chomp $cols;
$cols = $cols - 1;

sub print_column {
    my $id      = shift @_;
    my $stat    = shift @_;
    my $conn    = shift @_;
    my $tags    = shift @_;
    my $mem     = shift @_;
    my $disk    = shift @_;
    my $release = shift @_;
    system(
"printf '| %3s | %5s | %19s | %10s | %4s | %7s | %29s |\n' '$id' '$stat' '$conn' '$tags' '$mem' '$disk' '$release' | cut -c-$cols"
    );
}

print "\n";
print_column "id", "state", "ssh", "tag", "mem", "disk", "built";
print_column "--", "-----", "---", "---", "---", "----", "-----";

for my $container (`ls $dir | grep "$ip_prefix"`) {
    chomp $container;
    next if !$container;
    my $id   = `echo $container | cut -d "." -f 4`;
    my $full = "$dir/$container";
    my $disk = `du -h $full | tail -n 1 | awk '{print \$1}'`;
    chomp $id;
    chomp $disk;
    my $tags     = "";
    my $tag_file = "$full/tag";

    if ( -e $tag_file ) {
        $tags = `cat $tag_file`;
        chomp $tags;
    }
    my $status = "down";
    if ( system("screen -list | grep -q 'macrun$id\\s*'") == 0 ) {
        $status = "up";
    }
    my $env = `source $full/env && echo \$RELEASE && echo \$MEMORY`;
    chomp $env;
    my @parts = split( "\n", $env );
    my $built = $parts[0];
    my $mem   = $parts[1];
    print_column "$id", "$status", "root\@$container", "$tags", "$mem", "$disk",
      "$built";
}
print "\n";
