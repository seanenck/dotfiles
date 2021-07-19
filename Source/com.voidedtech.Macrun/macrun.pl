#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

my $bin = $ENV{"HOME"} . "/.bin/";
my $dir = $ENV{"MACRUN_STORE"};
my $ips = "192.168.64.";

die "no MACRUN_STORE set" if !$dir or !-d $dir;

die "sub command required" if !@ARGV;

my $arg = shift @ARGV;

sub create_tar {
    my $path    = shift @_;
    my $tarfile = "${path}settings.tar.xz";
    system("rm -f $tarfile");
    my $tempdir = `mktemp -d`;
    chomp $tempdir;
    my $cfg_file = "$tempdir/configure";
    system("echo '#!/bin/bash' > $cfg_file");
    system("mkdir -p $tempdir/root/.vim/");
    system("cp -r \$HOME/.vim/pack $tempdir/root/.vim/");
    system("echo 'cp -r root/.vim /root/.vim' >> $cfg_file");
    system("echo 'chown root:root -R /root/.vim/' >> $cfg_file");

    for my $file ( ".bashrc", ".vimrc", ".bash_profile", ".bash_aliases" ) {
        system("cp \$HOME/$file $tempdir/root/");
        system(
"echo 'install -Dm644 --owner=root --group=root root/$file /root/$file' >> $cfg_file"
        );
    }

    my $tag_file   = "${path}tag";
    my $macrun_cfg = $ENV{"HOME"} . "/.config/macrun/";
    if ( -e $tag_file ) {
        my $tag = `cat $tag_file`;
        chomp $tag;
        print "including $tag settings\n";
        for
          my $found (`find $macrun_cfg$tag/ -maxdepth 1 -type f -name "*.conf"`)
        {
            chomp $found;
            next if !$found;
            system("cat $found >> $cfg_file");
        }
    }
    system("cat ${macrun_cfg}macrun.conf >> $cfg_file");
    system("chmod u+x $cfg_file");
    system("cd $tempdir && tar cJf $tarfile *");
    system("rm -rf $tempdir");
}

if ( $arg eq "help" ) {
    print
      "build remove new tag start list screen stop configure killall destroy";
    exit;
}
elsif ( $arg eq "screen" ) {
    print "\n";
    print "screens\n=======\n";
    system(
        "screen -list | grep macrun | awk '{print \$1}' | sort | sed 's/^/  /g'"
    );
    print "\n";
    exit;
}
elsif ( $arg eq "new" ) {
    push( @ARGV, "start" );
    $arg = "build";
}
elsif ( $arg eq "killall" or $arg eq "destroy" ) {
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
        system("macrun stop $container");
        if ($destroy) {
            sleep 1;
            print "destroying: $container\n";
            system("macrun remove $container");
        }
    }
    exit 0;
}
elsif ($arg eq "tag"
    or $arg eq "remove"
    or $arg eq "configure"
    or $arg eq "start"
    or $arg eq "stop" )
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
    if ( $arg eq "stop" ) {
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

    if ( $arg eq "remove" ) {
        system("rm -rf $path");
    }
    elsif ( $arg eq "start" or $arg eq "configure" ) {
        system(
"cp \$HOME/Source/com.voidedtech.Macrun/scripts/setup-macrun.sh $path"
        );
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
            create_tar $path;
            system("ssh $use_host -- /etc/conf.d/setup-macrun");
        }
        print "ready! $use_host\n";
    }
    exit;
}

my $script = "${bin}macrun-$arg";

die "invalid contain command: $arg" if !-x $script;

system("$script @ARGV");
