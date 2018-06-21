install
===

Specific installs to my dev environment

# dirs

as enck
```
cd ~
mkdir -p ~/.cache
mkdir -p ~/.config/epiphyte
```

as root
```
mkdir -p /mnt/usb
mkdir -p ~/.vim/swap
mkdir -p ~/.vim/undo
```

copy data to usb from past environment as bootstrap (synced, etc, profiles, store/perm)
```
mount /dev/<disk> /mnt/usb
cd /mnt/usb
cp -r synced /home/enck/.synced
cp -r profiles/scratch /home/enck/.cache/scratch
cp -r profiles/.mozilla /home/enck/.mozilla
cp -r store /home/enck/store
cp etc/{files-one-by-one} /etc/{files-one-by-one}

chown -R enck:enck /home/enck/.synced
chown -R enck:enck /home/enck/.cache/scracth
chown -R enck:enck /home/enck/.mozilla
chown -R enck:enck /home/enck/store
cd ~
umount /mnt/usb
```

as enck setup home dir
```
cd ~
git init
git remote add origin https://github.com/enckse/home.git
git fetch
rm .bash*
git pull origin master
ln -s ~/.synced/gnupg .gnupg
# confirm gnupg dir settings
# edit ~/.git/config and change url to read/write
mkdir Downloads
mkdir .tmp
mkdir -p .vim/swap
mkdir -p .vim/undo
ln -s $HOME/.synced/configs/epiphyte.conf $HOME/.config/epiphyte/env
```

as root, finalize some dirs
```
rm -f /etc/vimrc
ln -s /home/enck/.vimrc /etc/vimrc
ln -s /home/enck/.bin/locking /usr/local/bin/
mkdir -p /etc/systemd/nspawn
```

services
```
timedatectl set-ntp true
systemctl enable iptables
```

package setup
```
# make sure pkgseed is installed
sudo pacman -Syyu
sudo pacman -Sc
sudo pacman-key --refresh-key
mkinitcpio -p linux
# make sure gpg keys for epiphyte are in place
# make sure configs are in place
# install from ~/.config/home/packages (groups first)
```

as enck, cleaning up/prep
```
systemctl --user enable sync.timer
systemctl --user enable maintain.timer
cd ~
mkdir -p $HOME/.cache/helper_cache
touch $HOME/.cache/helper_cache/tmp
cd ~/.bin
./helper_cache rebuild
```

as root, networking and reboot
```
systemctl enable systemd-networkd
systemctl enable wsw
reboot
```
