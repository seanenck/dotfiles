#!/usr/bin/env bash
MEMORY=4096
DISK=20
IP="ip=192.168.64.{IP}::192.168.64.1:255.255.255.0:{NAME}::none nameserver=192.168.1.1"
VMLINUZ="{STORAGE}/vmlinuz"
INITRD="{STORAGE}/initrd.img"
ISO="{STORAGE}/init.iso"

if [ -e "{STORAGE}/.cloud-init" ]; then
    IP=""
fi

chmod 644 $INITRD
chmod 644 $VMLINUZ
STORAGE="{STORAGE}/disk.img"
if [ ! -e $STORAGE ]; then
    cp "{RESOURCES}/image.raw" $STORAGE
    truncate -s ${DISK}G $STORAGE
fi

vftool \
    -m $MEMORY \
    -k $VMLINUZ \
    -i $INITRD \
    -d $STORAGE \
    -d $ISO \
    -t 0 \
    -a "console=hvc0 $IP root=/dev/vda2" &

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
