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

alias vi="$EDITOR"
alias vim="$EDITOR"
alias less="less -R"

if command -v go >/dev/null; then
  golint() {
    "$HOME/.local/libexec/golint"
  }
fi

update-packages() {
  "$HOME/.local/libexec/dotfiles-deploy"
}
