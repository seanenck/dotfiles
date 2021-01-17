#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

. /etc/voidedtech/bash/bashrc

source ~/.variables
if [ ! -e $HOST_TYPE ]; then
    host=$(hostnamectl status | grep "Static hostname" | cut -d ":" -f 2 | sed 's/\s*//g')
    echo $host > $HOST_TYPE
fi

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

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

export PASSWORD_STORE_DIR=$HOME/store/private

for file in $HOME/.pass/env $HOME/store/config/etc/private.exports; do
    if [ -e $file ]; then
        . $file
    fi
done

if [ -z "$SSH_CONNECTION" ]; then
    motd
    source ~/.local/share/applications/ide.app load
fi

if [ ! -z "$SCHROOT_CHROOT_NAME" ]; then
    PS1='[\u@${SCHROOT_CHROOT_NAME} \W]\$ '
fi
