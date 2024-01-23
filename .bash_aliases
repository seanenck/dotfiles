#!/usr/bin/env bash
alias cat=bat
alias diff="diff --color -u"
alias ls='ls --color=auto'
alias grep="rg"
alias vi="$EDITOR"
alias vim="$EDITOR"
alias scp="echo noop"

vm() {
  local name
  name=vfu-vm
  if screen -list 2>/dev/null | grep -q "$name"; then
    return
  fi
  screen -S "$name" -d -m vfu --config "$HOME/.local/vm/alpine.json"
}
