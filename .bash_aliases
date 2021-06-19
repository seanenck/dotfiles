#!/bin/bash
alias diff="diff -u"
alias ls='ls --color=auto'
alias duplicates="fdupes ."
alias grep="rg"

dirty-memory() {
    if [ -e /proc/meminfo ]; then
        watch -n 1 grep -e Dirty: -e Writeback: /proc/meminfo
    fi
}

full-apk-update() {
    if [ -x /sbin/apk ]; then
        apk update
        apk upgrade
        if [ -x /usr/bin/lxc-ls ]; then
            for f in $(lxc-ls); do
                lxc-attach -n $f -- apk update
                lxc-attach -n $f -- apk upgrade
            done
        fi
    fi
}
