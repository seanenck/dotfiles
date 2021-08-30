#!/usr/bin/env bash

_row() {
    printf "%20s | %6s | %6s | %10s\n" $1 $2 $3 $4
}

_output() {
    local name up tag ip ssh
    ip=$(get_ip_from_path $1)
    name=$(get_machine_name $ip)
    up="down"
    screen -list | grep -q $name
    if [ $? -eq 0 ]; then
        up="up"
    fi
    tag=""
    if [ -e $1/$VMR_TAG ]; then
        tag=$(cat $1/$VMR_TAG)
    fi
    _row "root@$ip" "$name" "$up" "$tag"
}

echo
_row "ssh" "name" "state" "tag"
_row "---" "----" "-----" "---"
for m in $(get_machines); do
    _output $m
done
echo
