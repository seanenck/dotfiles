#!/bin/bash
alias diff="diff -u"
alias ls='ls --color=auto'
alias duplicates="fdupes -r ."
alias grep="rg"

if [ -x /usr/bin/podman ]; then
pruneman() {
    local path found full act exp
    found=0
    for path in /mnt /mnt/data; do
        full=$path/container.d/
        if [ -d $full ]; then
            exp=$(ls $full | wc -l)
            act=$(podman ps --format="{{ .ID }}" | wc -l)
            if [ $exp -ne $act ]; then
                echo "cowardly quitting with mismatch between known and running containers"
                return
            fi
            echo "found necessary containers ($act of $exp)"
            echo
            sleep 1
            break
        fi
    done
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
