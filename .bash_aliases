alias diff="diff -u"
alias ls='ls --color=auto'
alias dd="sudo dd status=progress"
alias duplicates="find . -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate"
alias grep="rg"

dirty-memory() {
    watch -n 1 grep -e Dirty: -e Writeback: /proc/meminfo
}
