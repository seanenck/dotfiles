#!/bin/bash
_ready() {
    setup-timezone -z US/Michigan
    setup-ntp -c chrony
    setup-apkcache /var/cache/apk
    ln -sf $1 /root/store
}

_setupdisks() {
    local has store prof files vim
    store=/var/opt/store
    vim=$store/.vim
    prof=$store/.bash
    files=".bashrc .vimrc .bash_aliases"
    mkdir -p $prof $vim
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
        echo "source /root/.bashrc" > /root/.profile
        for f in $(echo $files); do
            ln -sf $prof/$f /root/$f
        done
        vimplug=/root/.vim/pack/dist/
        for f in $(ls $vim/); do
            echo "updating $f"
            git -C $vim/$f pull
        done
        mkdir -p $vimplug
        ln -sf $vim/ ${vimplug}start
        _ready $store
        return
    fi
    yes | setup-disk -m data /dev/vdb
    for f in $(echo $files); do
        cp /root/$f $prof/$f
    done
    git clone https://github.com/vim-airline/vim-airline $vim/vim-airline
    git clone https://github.com/dense-analysis/ale $vim/ale
    _ready $store
}

_setupdisks
