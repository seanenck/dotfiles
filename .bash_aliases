#!/usr/bin/env bash
if command -v bat > /dev/null; then
  alias cat=bat
fi
alias diff="diff --color -u"
alias ls='ls --color=auto'
if command -v rg > /dev/null; then
  alias grep="rg"
else
  alias grep="grep -Hn --label=[stdin] --color=auto"
fi
if command -v chroma > /dev/null; then
  chroma() {
    command chroma --style=vim $@ | nl
  }
fi
alias vi="$EDITOR"
alias vim="$EDITOR"
alias less="less -R"
