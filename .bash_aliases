#!/usr/bin/env bash
goupdate() {
  go get -u ./...
  go mod tidy
}

_glint() {
  revive ./... 2>&1 | sed "s/^/[revive]      -> /g"
  gofumpt -l -extra $(find . -type f -name "*.go") 2>&1 | sed "s/^/[gofumpt]    -> /g"
  staticcheck -checks all -debug.run-quickfix-analyzers ./... 2>&1 | sed "s/^/[staticcheck] -> /g"
  go vet ./... 2>&1 | sed "s/^/[govet]       -> /g"
}

glint() {
  if [ -d "vendor" ] ; then
    _glint | grep -v "vendor/"
  else
    _glint
  fi
}

sys-update() {
  local d c
  d="$TASK_CACHE/brew"
  for c in update upgrade; do
    if ! brew "$c"; then
      echo "brew $c failed!"
      return
    fi
  done
  rm -f "$d/Brewfile"
  mkdir -p "$d"
  if ! (cd "$d" && brew bundle dump); then
    echo "failed to dump brew definitions"
    return
  fi
  (cd "$HOME/.config/nvim" && ./user-updates update)
  d="$HOME/.local/state/repos.current"
  touch "$d"
  {
    for c in keepassxreboot/keepassxc kovidgoyal/kitty utmapp/UTM obsidianmd/obsidian-releases; do
      echo "getting data for: $c" 1>&2
      git ls-remote --tags "https://github.com/$c" | grep 'refs/tags/' | sed "s#^#$c: #g"
    done
  } > "$d.new"
  if ! diff "$d" "$d.new"; then
    echo "==="
    echo "application update detected"
    echo "==="
  fi
  mv "$d.new" "$d"
}

alias cat=bat
alias diff="diff --color -u"
alias ls='ls --color=auto'
alias grep="rg"
alias vi="$EDITOR"
alias vim="$EDITOR"
alias scp="echo noop"
alias utmctl="/Applications/UTM.app/Contents/MacOS/utmctl"
