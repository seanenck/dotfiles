#!/bin/bash
ENTRIES=$HOME/.config/window.entries
if [ -e $ENTRIES ]; then
    source $ENTRIES
fi

function enter()
{
    word=$1
    echo "please activate the window to enter the text into"
    sleep 3
    for i in $(seq 1 ${#word})
    do
        xdotool key ${word:i-1:1}
    done
    for i in ${@:2}; do
        xdotool key $i
    done
}

if [ -z $1 ]; then
    echo "must provide input"
else
    using=$1
    ran=0
    if [ -e $ENTRIES ]; then
        result=$($ENTRIES $using)
        if [ ! -z "$result" ]; then
            ran=1
            enter $result
        fi
    fi
    if [ $ran -eq 0 ]; then
        enter $@
    fi
fi
