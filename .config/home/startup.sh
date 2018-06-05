#!/bin/sh
if [ ! -e '/var/cache/.start' ]; then 
    echo ''
    echo '=====NOTICE====='
    echo 'performing first-time startup'
    echo '=====NOTICE====='
    echo ''
    sudo locale-gen
    sudo touch '/var/cache/.start'
fi
source /home/enck/.bash_aliases
