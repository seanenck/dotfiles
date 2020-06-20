#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# If not running interactively, don't do anything
. /etc/voidedtech/bash/bashrc
case $- in
    *i*) ;;
      *) return;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

for file in $HOME/.bash_aliases \
            /etc/voidedtech/bash/aliases \
            $HOME/.bash_completion \
            /usr/share/bash-completion/bash_completion \
            $HOME/.config/user-dirs.dirs; do
    . $file
done

if [[ ! $DISPLAY && XDG_VTNR -eq 1 ]]; then
    exec startx $HOME/.xinitrc 2>&1 | systemd-cat -t "xinit"
    exit
fi

export TERM=xterm
export GOPATH="$HOME/.cache/go"
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
if [ ! -z "$SCHROOT_CHROOT_NAME" ]; then
    PS1='[\u@${SCHROOT_CHROOT_NAME} \W]\$ '
    if [ ! -z "$SSH_AUTH_SOCK" ]; then
        export SSH_AUTH_SOCK="$SSH_AUTH_SOCK"
    fi
    return
fi

export CHROOT=~/store/chroots/builds
mkdir -p /dev/shm/schroot/overlay

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

for file in $HOME/.pass/env $HOME/store/personal/config/etc/private.exports; do
    . $file
done
