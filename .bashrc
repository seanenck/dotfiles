# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=-1

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
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

. ~/.bash_aliases

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#end-general

. $HOME/.bin/common
if [ -e "$EPIPHYTE_CONF" ]; then
    source $EPIPHYTE_CONF
fi
if [ -e "$PRIV_CONF" ]; then
    source $PRIV_CONF
fi

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

# things to do to setup shell/env
_setup() {
    BOOTED=$USER_TMP/".booted."$(uptime -s | sed "s/ /-/g;s/:/-/g")
    if [ ! -e $BOOTED ]; then
        rm -f $DISPLAY_UN
        rm -f $DISPLAY_EN
        rm -f $SND_MUTE
        rm -f $TRAY_SET
        rm -f $NET_SLEEP
        for f in $(find $USER_TMP -type f | grep "${PROFILE_TMP}"); do
            rm -f $f
        done
    fi
    process-pass-aliases
    set-system
    set-user-files
    tray
    docked
}

_ready() {
    _setup > $SETUP_LOG
}

_ready 
if [ -s $SETUP_LOG ]; then
    cat $SETUP_LOG
fi

if [ -e $GIT_CHANGES ]; then
    cat $GIT_CHANGES
    rm -f $GIT_CHANGES
fi

today_check=$USER_TMP/last.checked.$(date +%Y-%m-%d)
rm -f $today_check
if [ ! -e $today_check ]; then
    XERRORS=$HOME/.xsession-errors
    rm -r $XERRORS
    ln -s /dev/null $XERRORS
    process-logs
    touch $today_check
fi

check-timed-events
