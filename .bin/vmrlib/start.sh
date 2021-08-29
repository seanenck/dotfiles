#!/usr/bin/env bash
if [ -z "$1" ]; then
    echo "machine required"
    exit 1
fi

path=$(get_machine_path $1)
echo "$path"
if [ ! -d $path ]; then
    echo "invalid machine"
    exit 1
fi

name=$(get_machine_name $1)
screen -list | grep -q "$name"
if [ $? -eq 0 ]; then
    echo "machine already up"
    exit 1
fi

ip=$(get_ip $1)
screen -d -m -S $name -- $path/$VMR_START_SH

_ready() {
    ssh -o BatchMode=yes -o ConnectTimeout=5 -o PubkeyAuthentication=no -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no -o ChallengeResponseAuthentication=no $ip 2>&1 | grep -q "Permission denied"
    if [ $? -eq 0 ]; then
        echo "yes"
    else
        echo "no"
    fi
}

echo "waiting for machine..."
while [ 1 -eq 1 ]; do
    is_ready=$(_ready)
    if [[ "$is_ready" == "yes" ]]; then
        echo "machine up..."
        break
    fi
    sleep 3
done

from=""
tagfile=$path/$VMR_TAG
if [ ! -z "$2" ]; then
    if [[ "$2" != "-from" ]]; then
        echo "invalid start parameter"
        exit 1
    fi
    if [ -z "$3" ]; then
        echo "-from requires argument"
        exit 1
    fi
    if [ -e $tagfile ]; then
        echo "machine already tagged"
    else
        from="$3"
        echo "$from" > $tagfile
    fi
fi
if [ -e $tagfile ]; then
    from=$VMR_CONFIGS/$(cat $tagfile)
    if [ ! -d "$from" ]; then
        echo "invalid 'from' template, not found"
        exit 1
    fi
fi

settings=$path/settings.tar.xz
_configure() {
    local f tmpdir cwd
    cwd=$PWD
    tmpdir=$(mktemp -d)
    cd $tmpdir
    $VMR_CONFIGS/configure.sh
    if [ ! -z "$from" ]; then
        for f in $(find $from -type f | sort); do
            bash $f
        done
    fi
    tar cJf $settings .
    cd $cwd
}

config_sh=$path/configure
_configure > "$config_sh"
chmod u+x $config_sh
scp $VMRLIB/lib.bootstrap.sh $ip:/tmp/bootstrap.sh
scp $VMRLIB/lib.setup.sh $ip:/tmp/setup.sh
scp $settings $ip:/tmp/
scp $config_sh $ip:/tmp/
ssh $ip -- ash /tmp/bootstrap.sh
echo
echo
echo "              ssh root@$ip"
echo
echo
