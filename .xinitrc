#!/bin/sh
xrdb -merge $HOME/.Xresources
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi
while [ 1 ]; do
    startfluxbox
    sleep 1
done
