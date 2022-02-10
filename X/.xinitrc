#!/bin/sh
xrdb -merge $HOME/.Xresources

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

. /etc/profile
xset b off
xset b 0 0 0
xsetroot -solid "#333333"
while [ 1 -eq 1 ]; do
    if pgrep -x dwm > /dev/null; then
        sleep 0.5
    else
        echo "starting dwm"
        xbindkeys --poll-rc
        dwm &
    fi
    if pgrep -x xautolock > /dev/null; then
        sleep 0.5
    else
        echo "starting xautolock"
        xautolock -time 5 -locker $HOME/.local/bin/locker &
    fi
    sleep 1
done
