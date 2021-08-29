#!/usr/bin/env bash
STORE=/var/opt/root

_getip() {
    ip addr | grep "inet" | grep "192.168.64." | awk '{print $2}' | cut -d "/" -f 1 
}

_ready() {
    local settings ip
    ip=$(_getip)
    hostname $(echo $ip | cut -d "." -f 4 | sed 's/^/vmr-/g')
    setup-timezone -z US/Michigan
    setup-ntp -c chrony
    setup-apkcache /var/cache/apk
    /etc/init.d/loopback start
    if [ ! -d $STORE ]; then
        cp -r /root /var/opt
    fi
    mount --bind $STORE /root
    settings="settings.tar.xz"
    cwd=$PWD
    cd /tmp && tar xf $settings && ./configure && rm -f $settings
    cd $cwd
}

_setup() {
    local has
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
        _ready
        return
    fi
    yes | setup-disk -m data /dev/vdb
    _ready
}

_setup
