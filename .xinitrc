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
$HOME/.local/bin/wsw reload
$HOME/.local/bin/workspaces
$HOME/.local/bin/volume reset
has_trackpoint=$(xinput list | grep "TPPS/2 IBM TrackPoint")
if [ $has_trackpoint -eq 0 ]; then
    trackpoint=$(xinput list | grep "TPPS/2 IBM TrackPoint" | cut -d "=" -f 2 | tr '\t' ' ' | cut -d " " -f 1)
    speed=$(xinput list-props $trackpoint | grep "Accel Speed (" | cut -d "(" -f 2 | cut -d ")" -f 1)
    xinput set-prop $trackpoint $speed 1
    xinput set-prop "Synaptics TM3276-022" "Device Enabled" 0
fi
while [ 1 -eq 1 ]; do
    if pgrep -x dwm > /dev/null; then
        sleep 0.5
    else
        echo "starting dwm"
        xbindkeys --poll-rc
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
