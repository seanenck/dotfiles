#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

my $bin = $ENV{"HOME"} . "/.bin/";
my $dir = $ENV{"CONTAINER_BASE"};
my $ips = "192.168.64.";

die "no CONTAINER_BASE set" if !$dir or !-d $dir;

die "sub command required" if !@ARGV;

my $arg = shift @ARGV;

if ( $arg eq "help" ) {
    print "build purge ready tag start list kill reconfigure halt destroy";
    exit;
}
elsif ( $arg eq "ready" ) {
    push(@ARGV, "start");
    $arg = "build";
}
elsif ( $arg eq "halt" or $arg eq "destroy" ) {
    my $destroy = 0;
    if ( $arg eq "destroy" ) {
        $destroy = 1;
    }
    print "perform full macrun $arg? (y/N) ";
    my $input = <STDIN>;
    chomp $input;
    $input = lc $input;
    if ( $input ne "y" ) {
        exit 1;
    }
    for my $container (`ls $dir | grep $ips | cut -d "." -f 4`) {
        chomp $container;
        next if !$container;
        print "halting: $container\n";
        system("macrun kill $container");
        if ($destroy) {
            sleep 1;
            print "destroying: $container\n";
            system("macrun purge $container");
        }
    }
    exit 0;
}
elsif ($arg eq "tag"
    or $arg eq "purge"
    or $arg eq "reconfigure"
    or $arg eq "start"
    or $arg eq "kill" )
{

    die "container required" if !@ARGV;

    my $container = shift @ARGV;
    my $path      = "${dir}$ips$container/";

    die "invalid container: $path" if !-d $path;

    if ( $arg eq "tag" ) {
        die "tag required" if !@ARGV;
        my $tag = shift @ARGV;
        if ($tag) {
            open( my $fh, ">", "${path}tag" );
            print $fh "$tag\n";
        }
        exit;
    }

    my $name     = "macrun$container";
    my $sessions = `screen -list | grep "$name\\s*" | awk '{print \$1}'`;
    chomp $sessions;
    my $vftool =
`ps aux | grep -v "grep vftool" | grep -v "rg vftool" | grep vftool | grep ":$name:" | awk '{print \$2}'`;
    chomp $vftool;
    if ( $arg eq "kill" ) {
        for my $sess ( split( "\n", $sessions ) ) {
            print "killing session object: $sess\n";
            system("screen -X -S $sess quit");
        }
        sleep 1;
        for my $vf ( split( "\n", $vftool ) ) {
            print "killing vftool $vf\n";
            system("kill -9 $vf");
        }
        exit;
    }

    if ($sessions) {
        die "unable to operate on running instance with sessions";
    }
    if ($vftool) {
        die "found vftool running";
    }

    if ( $arg eq "purge" ) {
        system("rm -rf $path");
    }
    elsif ( $arg eq "start" or $arg eq "reconfigure" ) {
        system("screen -D -m -S $name -- bash ${path}start.sh &");
        print "starting...\n";
        my $use_host = "root\@$ips$container";
        my $output   = 0;
        while (
            system(
"ssh -o BatchMode=yes -o ConnectTimeout=5 -o PubkeyAuthentication=no -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no -o ChallengeResponseAuthentication=no $use_host 2>&1 | grep -q 'Permission denied'"
            ) != 0
          )
        {
            if ( $output == 0 ) {
                print "container not ready...\n";
            }
            $output = $output + 1;
            if ( $output >= 10 ) {
                $output = 0;
            }
            sleep 3;
        }
        if ( $arg eq "start" ) {
            print "setting up...\n";
            system("ssh $use_host -- /etc/conf.d/setup-macrun");
        }
        print "ready!\n";
    }
    exit;
}

my $script = "${bin}macrun-$arg";

die "invalid contain command: $arg" if !-x $script;

system("$script @ARGV");
