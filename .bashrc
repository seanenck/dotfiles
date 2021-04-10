#!/bin/bash
alias diff="diff -u"
alias ls='ls --color=auto'
alias duplicates="find . -type f -print0 | xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate"
alias grep="rg"

[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=-1

export VISUAL=vim
export EDITOR="$VISUAL"
export LESSHISTFILE=$HOME/.cache/lesshst
export TERM=xterm-256color
export PAGER=less
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""

PS1='[\u@\h \W]\$ '

# check the window size after each command
shopt -s checkwinsize

export GOPATH="$HOME/Library/Caches/go"
export RUSTUP_HOME="$HOME/.rust/rustup"
export CARGO_HOME="$HOME/.rust/cargo"
export PATH="$HOME/.bin:$GOPATH/bin/:$PATH"
source $CARGO_HOME/env
export LOCKBOX_STORE="/Users/enck/Git/passwords"
export LOCKBOX_KEYMODE="macos"
export LOCKBOX_TOTP="keys/totp/"

[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"
. /opt/homebrew/completions/bash/brew
eval "$(/opt/homebrew/bin/brew shellenv)"

_rust-comp() {
    completions=~/.completions/rustup.bash
    if [ ! -e $completions ]; then
        ~/.rust/cargo/bin/rustup completions bash > $completions
    fi
}

. ~/.bash_aliases
_rust-comp
for f in $(find ~/.completions -type f); do
    . $f
done

for f in coreutils gnu-tar  gnu-sed gawk findutils; do
    export PATH="$HOMEBREW_PREFIX/opt/$f/libexec/gnubin:$PATH"
done

gpga
export GPG_TTY=$(tty)
source ~/Git/personal/bashrc
