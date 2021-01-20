[[ $- != *i* ]] && return

for file in $HOME/.variables \
            /etc/voidedtech/bash/bashrc \
            $HOME/.bash_aliases \
            /etc/voidedtech/bash/aliases \
            $HOME/.bash_completion \
            $HOME/.config/private/etc/private.exports \
            /usr/share/bash-completion/bash_completion \
            $HOME/.config/user-dirs.dirs; do
    if [ -e $file ]; then
        . $file
    fi
done

# check the window size after each command
shopt -s checkwinsize

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

if [ -z "$SSH_CONNECTION" ]; then
    motd
    ide=~/.local/apps/enabled/ide.app
    if [ -e $ide ]; then
        source $ide load
    fi
fi

if [ ! -z "$SCHROOT_CHROOT_NAME" ]; then
    PS1='[\u@${SCHROOT_CHROOT_NAME} \W]\$ '
fi

if [ -d .mutt ]; then
    . ~/.mailrc
fi
