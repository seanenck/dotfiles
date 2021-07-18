#!/bin/bash
_setupdisks() {
    local has store prof files
    store=/var/opt/store
    prof=$store/.bash
    files=".bashrc .vimrc .bash_aliases"
    mkdir -p $prof
    has=0
    blkid | grep -q "vdb1"
    if [ $? -eq 0 ]; then
        swapon /dev/vdb1
        has=1
    fi
    blkid | grep -q "vdb2"
    if [ $? -eq 0 ]; then
        has=1
        mount /dev/vdb2 /var
    fi
    if [ $has -gt 0 ]; then
        setup-timezone -z US/Michigan
        setup-ntp -c chrony
        echo "source /root/.bashrc" > /root/.profile
        for f in $(echo $files); do
            ln -sf $prof/$f /root/$f
        done
        ln -sf $store /root/store
        return
    fi
    yes | setup-disk -m data /dev/vdb
    for f in $(echo $files); do
        cp /root/$f $prof/$f
    done
}

_setupdisks
