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

screen -d -m -S $name -- $path/$VMR_START_SH
