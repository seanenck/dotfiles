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

echo "ehco 'nameserver 1.1.1.1' > /etc/resolv.conf"

echo 'echo > /etc/apk/repositories'
_produce_repo() {
    echo "echo '$1http://$VMR_REMOTE_ADDRESS/alpine/$2' >> /etc/apk/repositories"
}
_produce_repo "#" "edge/testing"
_produce_repo "" "$VMR_ALPINE_MAJOR_MINOR/community"
_produce_repo "" "$VMR_ALPINE_MAJOR_MINOR/main"

echo "apk update"
for f in bash bash-completion docs e2fsprogs fdupes fzf git ripgrep vim fzf-vim; do
    echo "apk add $f"
done

echo 'sed -i "s#/bin/ash#/bin/bash#g" /etc/passwd'
echo "echo 'root:root' | chpasswd"
