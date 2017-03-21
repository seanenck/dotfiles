#!/bin/sh
CUSTOM_STATS=$HOME/.cache/i3stats
if [ -e $CUSTOM_STATS ]; then
    $CUSTOM_STATS
else
    i3status | while :
    do
        read line
        echo "$line" || exit 1
    done
fi
