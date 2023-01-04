#!/usr/bin/env bash
[[ $- != *i* ]] && return

export GOPATH="$HOME/.cache/go"
export GOFLAGS="-trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
export DELTA_PAGER="less -c -X"
export PATH="$HOME/.bin/:$PATH"
. /etc/bashrc

PS1="\$(git-uncommitted --pwd 2>/dev/null)$PS1"

for file in ".bashrc_local" ".bash_aliases" ".bash_completions"; do
    file="$HOME/$file"
    if [ -e "$file" ]; then
        source "$file"
    fi
done
unset file

if [ -n "$SSH_CONNECTION" ]; then
    export LOCKBOX_CLIP_OSC52=yes
fi

_not-pushed() {
    if ! git uncommitted --quiet; then
        echo
        echo "uncommitted:"
        git uncommitted | cut -d " " -f 1 | sort -u | sed "s#$HOME/##g" | sed 's/^/  -> /g'
        echo
    fi
}
_not-pushed
