#!/usr/bin/env bash
MEMORY=2048
DISK=10
IP="ip=192.168.64.{IP}:none:192.168.64.1:255.255.255.0:{NAME}::none:1.1.1.1:9.9.9.9"
VMLINUZ="{STORAGE}/vmlinuz"
INITRD="{STORAGE}/initrd.img"
ISO="{STORAGE}/alpine.iso"

chmod 644 $INITRD
chmod 644 $VMLINUZ
STORAGE="{STORAGE}/disk.img"
if [ ! -e $STORAGE ]; then
    touch $STORAGE
    truncate -s ${DISK}G $STORAGE
fi

vftool \
    -m $MEMORY \
    -k $VMLINUZ \
    -i $INITRD \
    -d $ISO \
    -d $STORAGE \
    -t 0 \
    -a "console=hvc0 modules=loop,squashfs,virtio $IP ssh_key='$(cat $HOME/.ssh/systems.pub)'" &

vftool_pid=$!
echo "vftool started $vftool_pid"

while [ 1 -eq 1 ]; do
    sleep 1
    ps -p $vftool_pid > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "vftools closed, exiting"
        break
    fi
done
