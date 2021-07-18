#!/bin/bash
STORE=/var/opt/store
VIM=$STORE/.vim
PROFILE=$STORE/.bash
DOTFILES=$PROFILE/dotfiles
SCRIPT=/tmp/macrun

_ready() {
    local vimplug
    mkdir -p $PROF $VIM
    setup-timezone -z US/Michigan
    setup-ntp -c chrony
    setup-apkcache /var/cache/apk
    /etc/init.d/loopback start
    ln -sf $STORE /root/store
    vimplug=/root/.vim/pack/dist/
    mkdir -p $vimplug
    ln -sf $VIM/ ${vimplug}start
    ln -sf $DOTFILES/.{bashrc,bash_aliases,vimrc} /root/
    ln -sf $DOTFILES/.bash_profile /root/
    ln -sf $DOTFILES/.bash_profile /root/.profile
}

_setup() {
    local has dir repo
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
        for dir in $(echo "$VIM $PROFILE"); do
            for repo in $(ls $dir); do
                echo "updating $repo ($dir)"
                git -C $dir/$repo pull
            done
        done
        return
    fi
    yes | setup-disk -m data /dev/vdb
    _ready
    git clone https://github.com/vim-airline/vim-airline $VIM/vim-airline
    git clone https://github.com/dense-analysis/ale $VIM/ale
    git clone https://cgit.voidedtech.com/dotfiles $DOTFILES
}

_getlatest() {
    wget --no-check-certificate -O $SCRIPT "https://cgit.voidedtech.com/dotfiles/plain/Source/com.voidedtech.Macrun/scripts/setup-macrun.sh"
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