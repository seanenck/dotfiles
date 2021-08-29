#!/usr/bin/env bash
if [ -z "$1" ]; then
    echo "machine/all required"
    exit 1
fi
machines=""
if [[ "$1" == "--all" ]]; then
    machines=$(get_machines)
else
    machines="$VMR_STORE/$VMR_IP$1"
    if [ ! -d $machines ]; then
        echo "invalid machine: $1"
        exit 1
    fi
fi
for f in $(echo $machines); do
    $VMRLIB/kill.sh $(get_number_from_ip $(get_ip_from_path $f))
    rm -rf $f
done
