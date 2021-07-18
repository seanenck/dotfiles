#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

my $dir       = $ENV{"CONTAINER_BASE"};
my $ip_prefix = "192.168.64.";

sub print_column {
    my $id   = shift @_;
    my $stat = shift @_;
    my $conn = shift @_;
    my $ip   = shift @_;
    my $size = shift @_;
    my $tags = shift @_;
    system(
"printf '| %4s | %5s | %14s | %15s | %7s | %15s |\n' '$id' '$stat' '$conn' '$ip' '$size' '$tags'"
    );
}

print "\n";
print_column "id", "state", "connect", "ip", "size", "tags";
print_column "--", "-----", "-------", "--", "----", "----";

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
    if ( system("screen -list | grep -q 'macvm$id\\s*'") == 0 ) {
        $status = "up";
    }
    print_column "$id", "$status", "root\@macvm.$id", "$container", "$size",
      "$tags";
}
print "\n";
