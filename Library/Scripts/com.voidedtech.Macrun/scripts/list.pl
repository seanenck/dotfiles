#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

my $dir       = $ENV{"CONTAINER_BASE"};
my $ip_prefix = "192.168.64.";

sub print_column {
    my $id      = shift @_;
    my $stat    = shift @_;
    my $conn    = shift @_;
    my $tags    = shift @_;
    my $ip      = shift @_;
    my $size    = shift @_;
    my $release = shift @_;
    system(
"printf '| %3s | %5s | %8s | %10s | %14s | %7s | %29s |\n' '$id' '$stat' '$conn' '$tags' '$ip' '$size' '$release'"
    );
}

print "\n";
print_column "id", "state", "ssh", "tag", "ip", "size", "release";
print_column "--", "-----", "---", "---", "--", "----", "-------";

for my $container (`ls $dir | grep "$ip_prefix"`) {
    chomp $container;
    next if !$container;
    my $id   = `echo $container | cut -d "." -f 4`;
    my $full = "$dir/$container";
    my $size = `du -h $full | tail -n 1 | awk '{print \$1}'`;
    chomp $id;
    chomp $size;
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
    my $release = `cat $full/built`;
    chomp $release;
    print_column "$id", "$status", "root\@$id", "$tags", "$container", "$size",
      "$release";
}
print "\n";
