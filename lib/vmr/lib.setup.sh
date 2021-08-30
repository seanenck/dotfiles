#!/usr/bin/env bash
STORE=/var/opt/root
SETTINGS="settings.tar.xz"
CONFIGURE="configure"

_getip() {
    ip addr | grep "inet" | grep "192.168.64." | awk '{print $2}' | cut -d "/" -f 1 
}

_motd() {
    echo
    echo "vmr"
    echo "  name: $1"
    echo "  date: "$(date +%Y-%m-%dT%H:%M:%S)
    echo
}

_ready() {
    local ip
    ip=$(_getip | cut -d "." -f 4 | sed 's/^/vmr-/g')
    hostname $ip
    setup-timezone -z US/Michigan
    setup-apkcache /var/cache/apk
    apk add --quiet chrony acf-core
    /etc/init.d/chronyd start
    /etc/init.d/loopback start
    if [ ! -d $STORE ]; then
        cp -r /root /var/opt
    fi
    mount --bind $STORE /root
    _motd $ip > /etc/motd
    cwd=$PWD
    cd /tmp && tar xf $SETTINGS && ./$CONFIGURE
    cd $cwd
    rm -f /tmp/$SETTINGS /tmp/$CONFIGURE /tmp/setup.sh /tmp/bootstrap.sh
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
