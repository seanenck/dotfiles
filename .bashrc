#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

. /etc/voidedtech/bash/bashrc

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

if [[ ! $DISPLAY && XDG_VTNR -eq 1 ]]; then
    exec startx $HOME/.xinitrc 2>&1 | systemd-cat -t "xinit"
    exit
fi

export TERM=xterm
export PAGER=less
export BROWSER=firefox-developer-edition
export GOPATH="$HOME/.cache/go"
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
if [ ! -z "$SCHROOT_CHROOT_NAME" ]; then
    for f in $(ls ~/.local/bin); do
        alias $f="echo '$f not available in schroot'"
    done
    PS1='[\u@${SCHROOT_CHROOT_NAME} \W]\$ '
    if [ ! -z "$SSH_AUTH_SOCK" ]; then
        export SSH_AUTH_SOCK="$SSH_AUTH_SOCK"
    fi
    return
fi

alias mail="sys mail"
for f in vlc mutt mumble $BROWSER; do
    alias $f="echo disabled in bash"
done

firefox() {
    /usr/bin/$BROWSER "$@" &
    disown
}

if [ -x /usr/bin/mutt ]; then
    fastmail() {
        /usr/bin/mutt -F ~/.mutt/fastmail.muttrc
    }
fi

export CHROOT=/opt/chroots/builds
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

localdev dl
