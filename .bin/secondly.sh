#!/bin/bash
source /home/enck/.bin/common
HAS_RAN=/tmp/.systeminit
if [ ! -e $HAS_RAN ]; then
    rm -f $DISPLAY_UN
    rm -f $DISPLAY_EN
    rm -f $SND_MUTE
    rm -f $TRAY_SET
    for f in $(find $USER_TMP -type f | grep "${PROFILE_TMP}"); do
        rm -f $f
    done
    touch $HAS_RAN
fi
if [ ! -e $GIT_CHANGES ]; then
    git-changes > $GIT_CHANGES
fi
