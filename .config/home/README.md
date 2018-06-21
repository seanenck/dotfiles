install
===

Specific installs to my dev environment

# dirs

as root
```
mkdir -p /mnt/usb
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

