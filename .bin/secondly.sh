#!/bin/bash
source /home/enck/.bin/common
if [ -e $GIT_CHANGES ]; then
    last=$(stat $GIT_CHANGES | grep ^Modify | cut -d " " -f 2,3 | cut -d "." -f 1)
    last_d=$(date -d "$last" +%s)
    cur_d=$(date -d "1 minute ago" +%s)
    if [ $last_d -lt $cur_d ]; then
        rm -f $GIT_CHANGES
    fi
fi
if [ ! -e $GIT_CHANGES ]; then
    git-changes > $GIT_CHANGES
fi
