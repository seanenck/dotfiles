#!/bin/bash
alias diff="diff -u"
alias ls='ls --color=auto'
alias duplicates="fdupes -r ."
alias grep="rg"

if [ -x /usr/bin/podman ]; then
pruneman() {
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
