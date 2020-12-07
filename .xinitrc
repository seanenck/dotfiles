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
wsw reload
if [ -z "$IS_DESKTOP" ]; then
    xrandr --output eDP-1 --mode 2560x1440
else
    xrandr --output DP-2-8 --mode 2560x1440
    xrandr --output DP-2-1-8 --right-of DP-2-8 --mode 2560x1440 --rotate right
fi
xinput list | grep -q "TPPS/2 IBM TrackPoint"
if [ $? -eq 0 ]; then
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
    if pgrep -x locking > /dev/null; then
        sleep 0.5
    else
        echo "starting locking"
        locking &
    fi
    sleep 1
done
