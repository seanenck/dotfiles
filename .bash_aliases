#!/bin/bash
alias diff="diff -u"
alias ls='ls --color=auto'
alias duplicates="fdupes -r ."
alias grep="rg"

if [ -x /usr/bin/podman ]; then
pruneman() {
    local y
    echo
    echo "this will prune all podman extraneous objects"
    echo "make sure any containers of interest ARE RUNNING"
    echo
    read -p "continue? (Y/n)" y
    echo
    if [[ "$y" == "n" ]]; then
        return
    fi
    podman image prune
    podman container prune
    podman volume prune
}
fi

if [ -e /proc/meminfo ]; then
dirty-memory() {
    watch -n 1 grep -e Dirty: -e Writeback: /proc/meminfo
}
fi
