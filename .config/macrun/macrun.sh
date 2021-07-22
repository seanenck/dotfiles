#!/bin/bash

echo "cp -r root/.vim /root/.vim"
echo "chown root:root -R /root/.vim/"

mkdir -p root/.vim/
cp -r $HOME/.vim/pack root/.vim/pack

for f in .bashrc .bash_aliases .vimrc .bash_profile; do
    cp $HOME/$f root/$f
    echo "install -Dm644 --owner=root --group=root root/$f /root/$f"
done
