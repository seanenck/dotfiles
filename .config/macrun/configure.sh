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
    echo "echo '$1http://dl-cdn.alpinelinux.org/alpine/$2' >> /etc/apk/repositories"
}
_produce_repo "#" "edge/testing"
_produce_repo "" "$MACRUN_ALPINE_VERSION/community"
_produce_repo "" "$MACRUN_ALPINE_VERSION/main"

if [ $MACRUN_LOCAL -eq 1 ]; then
    echo "sed -i 's/dl-cdn.alpinelinux.org/$MACRUN_REMOTE/g' /etc/apk/repositories"
fi
echo "apk update"
for f in bash bash-completion docs e2fsprogs fdupes fzf fzf-vim git ripgrep vim; do
    echo "apk add $f"
done
echo "apk fix"

echo 'sed -i "s#/bin/ash#/bin/bash#g" /etc/passwd'
echo "echo 'root:root' | chpasswd"
