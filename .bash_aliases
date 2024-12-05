#!/usr/bin/env bash
if command -v bat > /dev/null; then
  alias cat=bat
fi
alias diff="diff --color -u"
alias ls='ls --color=auto'
if command -v rg > /dev/null; then
  alias grep="rg"
else
  alias grep="grep --color=auto"
fi
review() {
  if [ -n "$1" ]; then
    command nvim $@
    return
  fi
  command nvim -R +"set nofoldenable" -
}
alias vi="$EDITOR"
alias vim="$EDITOR"
alias less="less -R"
