#!/bin/sh
if [ ! -e '/var/cache/.start' ]; then 
    echo ''
    echo '=====NOTICE====='
    echo 'performing first-time startup'
    echo '=====NOTICE====='
    echo ''
    sudo locale-gen
    sudo chmod 644 /etc/environment
    sudo touch '/var/cache/.start'
fi
DISPLAY=:0
export DISPLAY
source /home/enck/.bash_aliases
