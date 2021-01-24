#!/bin/sh
xrdb -merge $HOME/.Xresources
while [ 1 ]; do
    startfluxbox
    sleep 1
done
