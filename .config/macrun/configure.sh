#!/usr/bin/env bash

echo "cp -r root/.vim /root/.vim"
echo "chown root:root -R /root/.vim/"

mkdir -p root/.vim/
cp -r $HOME/.vim/pack/ root/.vim/

for f in .bashrc .bash_aliases .vimrc .bash_profile; do
    cp $HOME/$f root/$f
    echo "install -Dm644 --owner=root --group=root root/$f /root/$f"
done
echo "sed -i \"s/system('uname')/'Darwin'/g\" /root/.vimrc"
echo "sed -i \"s#/opt/local/share/fzf/vim#/usr/share/vim/vimfiles/plugin/fzf.vim#g\" /root/.vimrc"

echo 'echo "#@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories'

curl -s http://netctl.voidedtech.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo 'sed -i "s/dl-cdn.alpinelinux.org/192.168.1.1:8888/g" /etc/apk/repositories'
fi
echo "apk update"
echo "apk fix"
