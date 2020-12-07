#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

. /etc/voidedtech/bash/bashrc

export DESKTOP=novel
export LAPTOP=margin
export SERVER=shelf
export TERM=xterm
export PAGER=less
export BROWSER=firefox-developer-edition
export GOPATH="$HOME/.cache/go"
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""

# check the window size after each command
shopt -s checkwinsize

for file in $HOME/.bash_aliases \
            /etc/voidedtech/bash/aliases \
            $HOME/.bash_completion \
            /usr/share/bash-completion/bash_completion \
            $HOME/.config/user-dirs.dirs; do
    if [ -e $file ]; then
        . $file
    fi
done

if [ ! -z "$SCHROOT_CHROOT_NAME" ]; then
    PS1='[\u@${SCHROOT_CHROOT_NAME} \W]\$ '
    if [ ! -z "$SSH_AUTH_SOCK" ]; then
        export SSH_AUTH_SOCK="$SSH_AUTH_SOCK"
    fi
    return
fi

mkdir -p /dev/shm/schroot/overlay

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

for file in $HOME/.pass/env $HOME/store/personal/config/etc/private.exports; do
    if [ -e $file ]; then
        . $file
    fi
done
