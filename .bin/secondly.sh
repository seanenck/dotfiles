#!/bin/bash
source /home/enck/.bin/common
if [ ! -e $GIT_CHANGES ]; then
    git-changes > $GIT_CHANGES
fi
