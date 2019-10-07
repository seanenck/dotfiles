#!/bin/sh
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
localbin=$HOME/.local/bin

# merge in defaults and keymaps
if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Source system and local profile
. /etc/profile
. $HOME/.profile
deviceid=$(xinput list | sed -n '/TPPS/s%.*id=\([0-9]\+\).*%\1%p')
accel=$(xinput list-props "$deviceid" | sed -n '/Accel\ Speed\ (/s%.*Accel Speed (\([0-9]\+\)).*%\1%p')
xinput set-prop "$deviceid" "$accel" -0.25
xinput set-prop $(xinput | grep "Finger" | sed -n -e 's/^.*id=//p' | sed -e "s/\s/ /g" | cut -d " " -f 1) "Device Enabled" 0
xset b off
xset b 0 0 0
xsetroot -solid "#333333"
$localbin/xinitdaemon -bin $localbin -home $HOME > /tmp/.xinitdaemon
