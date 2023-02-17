#!/usr/bin/env bash
alias cat=bat
alias diff="diff -u"
alias ls='ls --color=auto'
alias grep="rg"
alias vi="$EDITOR"
alias vim="$EDITOR"
alias scp="rsync"

unpack-rpm() {
  if [ -z "$1" ]; then
    echo "rpm required"
    return
  fi
  rpm2cpio "$1" | cpio -idmv
}
