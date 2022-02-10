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
    if ! pgrep -x pipewire > /dev/null; then
        pipewire --config $HOME/.config/pipewire.conf &
    fi
    if ! pgrep -x dwm > /dev/null; then
        echo "starting dwm"
        xbindkeys --poll-rc
        dwm &
        dbus-launch --exit-with-x11
    fi
    if ! pgrep -x xautolock > /dev/null; then
        echo "starting xautolock"
        xautolock -time 30 -locker slock &
    fi
    if ! pgrep -x status > /dev/null; then
        status &
    fi
    sleep 1
done
