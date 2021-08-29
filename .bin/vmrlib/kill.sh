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
