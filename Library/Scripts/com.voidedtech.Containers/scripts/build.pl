#!/opt/local/bin/perl
use strict;
use warnings;
use autodie;

my $release = "3.14.0";
my $size    = "1G";
my $ip_prefix = "192.168.64.";

my $version = `echo '$release' | rev | cut -d '.' -f 2- | rev`;
chomp $version;

my $directory = $ENV{"CONTAINER_BASE"};

my $workdir = "${directory}releases/";
my $current = "$workdir$release/";
my $apkovl  = "macvm.apkovl.tar.gz";
my $apkdir  = "$workdir$apkovl";
die "no apkovl at $apkdir" if !-e $apkdir;

my $iso =
"https://dl-cdn.alpinelinux.org/alpine/v$version/releases/aarch64/alpine-standard-$release-aarch64.iso";
my $iso_name = "boot.iso";

system("mkdir -p $directory");
my $iso_file = "$current/$release.iso";
if ( !-d $current ) {
    print "downloading release $release\n";
    system("mkdir -p $current");
    print "$iso\n";
    die "unable to download iso" if system("curl '$iso' > $iso_file") != 0;
    my $unpack = "${current}unpack";
    system("mkdir -p $unpack");
    die "unable to unpack " if system("isox $iso_file $unpack") != 0;
    system("cp $unpack/boot/vmlinuz_lts. $unpack/vmlinuz-lts.gz");
    system("cp $unpack/boot/initramfs_lts. $unpack/initramfs-lts");
    die "unable to gzip vmlinuz" if system("cd $unpack && gzip -d *.gz") != 0;
    system("mv $unpack/*-lts $current");
    system("rm -rf $unpack");
}

my $count = 2;
my $made  = 0;
my $path  = "";
while ( $count <= 254 ) {
    $path = "${directory}$ip_prefix$count/";
    if ( -d $path ) {
        $count = $count + 1;
        next;
    }
    print "creating $path\n";
    system("mkdir -p $path");
    system("cp $iso_file ${path}$iso_name");
    system("cp ${current}*-lts ${path}");
    system("cp $apkdir $path");
    system("mkdir -p ${path}store");
    die "unable to make store"
      if system(
"cd $path && hdiutil create storage -size $size -srcfolder store/ -fs exFAT -format UDRW"
      ) != 0;
    $made = 1;
    last;
}

die "unable to make a new container" if $made == 0;

my $http_port = `printf 7%03d '$count'`;
chomp $http_port;
my $host = "macvm$count";

my %parameters;
$parameters{"MEMORY"} = "512";
$parameters{"ISO"} = $iso_name;
$parameters{"HTTPPORT"} = $http_port;
$parameters{"SSHKEYS"} = "https://cgit.voidedtech.com/dotfiles/plain/.ssh/pubkeys";
$parameters{"IP"} = "$ip_prefix$count:none:192.168.64.1:255.255.255.0:${host}::none:1.1.1.1";
$parameters{"REPO"} = "http://dl-cdn.alpinelinux.org/alpine/v$version/main";

my $param_file = "${path}env";
open(my $fh, ">", $param_file);
for my $param (keys %parameters) {
    my $value = $parameters{$param};
    print $fh "export $param='$value'\n";
}

my $script_file = "${path}start.sh";
open(my $sh, ">", $script_file);
print $sh "#!/opt/local/bin/bash\n";
print $sh "cd $path\n";
print $sh "source $param_file\n";
print $sh "_httpserver() {\n";
print $sh "  python3 -m http.server \$HTTPPORT --bind 0.0.0.0\n";
print $sh "}\n";
print $sh "\n";
print $sh "_httpserver &\n";
print $sh "\n";
print $sh "PARAMS=\"ssh_key=\$SSHKEYS\"\n";
print $sh "PARAMS=\"\$PARAMS ip=\$IP\"\n";
print $sh "PARAMS=\"\$PARAMS apkovl=http://${ip_prefix}1:\$HTTPPORT/$apkovl\"\n";
print $sh "PARAMS=\"\$PARAMS alpine_repo=\$REPO\"\n";
print $sh "\n";
print $sh "vftool \\\n";
print $sh "  -m \$MEMORY \\\n";
print $sh "  -k vmlinuz-lts \\\n";
print $sh "  -i initramfs-lts \\\n";
print $sh "  -d \$ISO \\\n";
print $sh "  -a \"console=hvc0 modules=loop,squashfs,virtio \$PARAMS\"\n";
