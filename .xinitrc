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
. $HOME/.profile
xset b off
xset b 0 0 0
xsetroot -solid "#333333"
wsw --mode online
if [ $? -ne 0 ]; then
    wsw reload
fi
$HOME/.local/bin/workspaces mobile
$HOME/.local/bin/volume mute
find /home/enck/.vim/swap/ -type f -mtime +1 -exec rm {} \;
find /home/enck/.vim/undo/ -type f -mtime +1 -exec rm {} \;
while [ 1 -eq 1 ]; do
    if pgrep -x dwm > /dev/null; then
        sleep 0.5
    else
        echo "starting dwm"
        dwm &
    fi
    if pgrep -x dunst > /dev/null; then
        sleep 0.5
    else
        echo "starting dunst"
        dunst -config $HOME/.config/dunst &
    fi
    if pgrep -x status > /dev/null; then
        sleep 0.5
    else
        echo "starting status"
        status &
    fi
    if pgrep -x xautolock > /dev/null; then
        sleep 0.5
    else
        echo "starting xautolock"
        xautolock -time 5 -locker $HOME/.local/bin/locker &
    fi
    sleep 1
done
