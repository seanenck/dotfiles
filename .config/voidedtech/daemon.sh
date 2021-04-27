#!/bin/bash
DIR=/Users/enck/.daemon/
while [ 1 -eq 1 ]; do
    if [ -d $DIR ]; then
        for f in $(find $DIR -type f); do
            if [ -x $f ]; then
                $f
            fi
        done
    fi
    sleep 1
done
