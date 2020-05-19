#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=-1

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

. ~/.bash_aliases
. ~/.bash_completion
. /usr/share/bash-completion/bash_completion

if [[ ! $DISPLAY && XDG_VTNR -eq 1 ]]; then
    export MESA_LOADER_DRIVER_OVERRIDE=i965
    exec startx $HOME/.xinitrc > /tmp/xinit.log 2>&1
    return
fi

export TERM=xterm
export VISUAL=vim
export EDITOR="$VISUAL"
export GOPATH="$HOME/.cache/go"
source ~/.config/user-dirs.dirs
if [ ! -z "$SCHROOT_CHROOT_NAME" ]; then
    PS1='[\u@${SCHROOT_CHROOT_NAME} \W]\$ '
    return
fi

export CHROOT=~/store/chroots/builds
mkdir -p /dev/shm/schroot/overlay

# ssh agent
# Set SSH to use gpg-agent
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

# gpg setup
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

export UNREAL_SRC=$(readlink ~/store/unreal/current)

source ~/.pass/env
source ~/store/personal/config/etc/private.exports
