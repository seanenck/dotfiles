# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTFILE=/dev/null
HISTSIZE=-1
HISTFILESIZE=-1

# less
LESSHISTFILE=$HOME/.cache/lesshst

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\u@\h:\W> \[$(tput sgr0)\]"
    ;;
esac

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    $HOME/.bin/maintain boot &
    exec startx $HOME/.xinitrc
    return
fi

. ~/.bash_aliases

if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

export VISUAL=vim
export EDITOR="$VISUAL"

. $HOME/.bin/common

EPIPHYTE_CONF=${HOME_CONF}epiphyte/env
if [ -e "$EPIPHYTE_CONF" ]; then
    source $EPIPHYTE_CONF
fi
if [ -e "$PRIV_CONF" ]; then
    source $PRIV_CONF
    source /usr/share/bash-completion/completions/pass
    for i in $(echo "$PASS_ALIASES"); do
        alias pass-$i="PASSWORD_STORE_DIR=${PERM_LOCATION}pass-$i pass"
        eval '_pc_'$i'() { PASSWORD_STORE_DIR='${PERM_LOCATION}'pass-'$i'/ _pass; }'
        complete -o filenames -o nospace -F _pc_$i pass-$i
    done
    alias totp="totp $TOTP_PASS \$@"
    for i in $(echo "$LUKS_ENTRIES"); do
        n=$(echo "$i" | cut -d "/" -f 1)
        alias luks-$n='xwindows $(PASSWORD_STORE_DIR='${PERM_LOCATION}$LUKS_PASS' '$LUKS_PASS' show '$i'/luks 2>&1)'
    done
fi

# sbh implementation
_history-tree() {
    source ${HOME_BIN}sbh
    _sbh-write
}

PROMPT_COMMAND=_history-tree

# ssh agent
# Set SSH to use gpg-agent
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
fi
echo $SSH_AUTH_SOCK > $SSH_AUTH_TMP

# chroot
CHROOT=$CHROOT_LOCATION
export CHROOT

# gpg setup
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
if [ -s $GIT_CHANGES ]; then
    cat $GIT_CHANGES 2>/dev/null
    rm -f $GIT_CHANGES
    touch $UPDATE_STATS
fi

_check_today() {
    local f yesterday
    yesterday=$(date -d "1 day ago" +%Y-%m-%d)
    f=$USER_TMP/.journal.$yesterday
    if [ ! -e $f ]; then
        cat /var/log/sysmon.log | grep "^$yesterday" | grep -v "^$yesterday run:" >> $USER_JOURNAL
        touch $f
    fi
    xhost +local: >/dev/null
}
_check_today
