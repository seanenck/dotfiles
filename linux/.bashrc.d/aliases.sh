#!/usr/bin/env bash
if [ -x /usr/bin/bat ];then
  alias cat=bat
fi
alias diff="diff --color -u"
alias ls='ls --color=auto'
if [ -x /usr/bin/rg ]; then
  alias grep="rg"
fi
alias vi="$EDITOR"
alias vim="$EDITOR"
alias scp="echo noop"
