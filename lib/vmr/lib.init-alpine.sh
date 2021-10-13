#!/bin/ash
echo "root:root" | chpasswd
echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/main" > /etc/apk/repositories
echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" >> /etc/apk/repositories
setup-timezone -z US/Michigan
setup-hostname {NAME}
printf "y\n" | setup-disk -m data /dev/vdb
swapon /dev/vdb1
/etc/init.d/swap start
mkdir -p /var/cache/root
cp -r /root/.ssh /var/cache/root/
mount --bind /var/cache/root /root
echo > /etc/motd
hostname {NAME}
apk add bash bash-completion docs git make
sed -i "s#bin/ash#bin/bash#g" /etc/passwd
