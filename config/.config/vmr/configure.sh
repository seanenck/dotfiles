#!/usr/bin/env bash

PACK_FILES=1
if [ ! -z "$VMR_DISK_INIT" ]; then
    if [ $VMR_DISK_INIT -eq 1 ]; then
        PACK_FILES=0
    fi
fi

date +"%Y-%m-%dT%H:%M:%S" > last-updated
if [ $PACK_FILES -eq 1 ]; then
    mkdir -p root/.vim/
    cp -r $HOME/.vim/pack/ root/.vim/

    echo "if [ ! -e /root/.last-updated ]; then"
    echo "    cp -r root/.vim /root/.vim"
    echo "    chown root:root -R /root/.vim/"
    for f in .bashrc .bash_aliases .vimrc .bash_profile; do
        cp $HOME/$f root/$f
        echo "    install -Dm644 --owner=root --group=root root/$f /root/$f"
    done
    echo "    sed -i \"s/system('uname')/'Darwin'/g\" /root/.vimrc"
    echo "    cp last-updated /root/.last-updated"
    echo "fi"
fi

echo "echo 'nameserver $VMR_DNS' > /etc/resolv.conf"

echo 'echo > /etc/apk/repositories'
_produce_repo() {
    echo "echo '$1http://$VMR_REMOTE_ADDRESS/alpine/$2' >> /etc/apk/repositories"
}
_produce_repo "#@testing " "edge/testing"
_produce_repo "" "$VMR_ALPINE_MAJOR_MINOR/community"
_produce_repo "" "$VMR_ALPINE_MAJOR_MINOR/main"

echo "apk update"
echo "apk add bash bash-completion docs e2fsprogs fdupes git ripgrep vim"

echo 'sed -i "s#/bin/ash#/bin/bash#g" /etc/passwd'
echo "echo 'root:root' | chpasswd"
