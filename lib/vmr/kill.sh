#!/usr/bin/env bash
if [ -z "$1" ]; then
    echo "machine required"
    exit 1
fi

if [[ "$1" == "--all" ]]; then
    for f in $(get_machines); do
        number=$(get_number_from_ip $(get_ip_from_path $f))
        $VMRLIB/kill.sh $number
    done
    killall vftool
    exit 0
fi

path=$(get_machine_path $1)
echo "$path"
if [ ! -d $path ]; then
    echo "invalid machine"
    exit 1
fi

name=$(get_machine_name $1)
tty=$(screen -list 2>&1 | grep "$name" | awk '{print $1}')
if [ -z "$tty" ]; then
    echo "no sessions found"
    exit 1
fi
screen -X -S $tty quit
pid=$(ps aux | grep vftool | grep $name | awk '{print $2}')
if [ ! -z "$pid" ]; then
    kill -9 $pid
fi
