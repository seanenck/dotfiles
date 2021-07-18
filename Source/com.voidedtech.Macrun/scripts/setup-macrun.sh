#!/bin/bash
STORE=/var/opt/store
SCRIPT=/tmp/macrun

_httphost() {
    cat /proc/cmdline  | tr ' ' '\n' | grep "apkovl=" | cut -d "=" -f 2 | cut -d "/" -f 1,2,3
}

_ready() {
    local host settings
    host=$(_httphost)
    setup-timezone -z US/Michigan
    setup-ntp -c chrony
    setup-apkcache /var/cache/apk
    /etc/init.d/loopback start
    mkdir -p $STORE
    ln -sf $STORE /root/store
    settings="settings.tar.xz"
    wget -O /tmp/$settings "$host/settings.tar.xz"
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

_getlatest() {
    local host
    host=$(_httphost)
    wget -O $SCRIPT "$host/setup-macrun.sh"
    if [ $? -ne 0 ]; then
        cp /etc/conf.d/setup-macrun $SCRIPT
    fi
}

if [ ! -e $SCRIPT ]; then
    _getlatest
    bash $SCRIPT
else
    _setup
fi
