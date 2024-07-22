#!/usr/bin/env bash
if command -v batcat > /dev/null; then
  alias cat=batcat
else
  alias cat=bat
fi
alias diff="diff --color -u"
alias ls='ls --color=auto'
alias grep="rg"
alias vi="$EDITOR"
alias vim="$EDITOR"
