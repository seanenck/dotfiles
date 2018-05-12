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
HISTFILE="$USER_TMP/.bash_history_"$(uptime -s | sed "s/ /-/g;s/:/-/g")
EPIPHYTE_CONF=${HOME_CONF}epiphyte/env
if [ -e "$EPIPHYTE_CONF" ]; then
    source $EPIPHYTE_CONF
fi
if [ -e "$PRIV_CONF" ]; then
    source $PRIV_CONF
fi

function _history-tree()
{
    source $HOME/.bin/common
    local last chr path lck
    lck=$SBH_LOCK
    path="$SBH_STORE"
    if [ ! -d "$path" ]; then
        mkdir -p $path
    fi
    last=$(fc -ln 1 | tail -n 1 | sed "1s/^[[:space:]]*//")
    if [ ! -z "$last" ]; then
        chr=${last::1}
        chr=$(echo "$chr" | tr '[:upper:]' '[:lower:]')
        if [[ "$chr" =~ [^a-z0-9] ]]; then
            chr="special"
        fi
        path=${path}$chr".history"
        cnt=0
        while [ -e $lck ]; do
            sleep 0.1
            cnt=$((cnt+1))
            if [ $cnt -eq 10 ]; then
                echo "bh was locked..."
                rm -f $lck
            fi
        done
        touch $lck
        if [ ! -e "$path" ]; then
            touch $path
        fi
        grep -qF "$last" "$path" || echo "$last" >> "$path"
        rm -f $lck
    fi
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
systemctl start --user status.service
clear
if [ -e $GIT_CHANGES ]; then
    cat $GIT_CHANGES 2>/dev/null
    rm -f $GIT_CHANGES
fi

_setup() {
    # disable touchpad
    xinput set-prop $(xinput | grep "SynPS/2" | sed -n -e 's/^.*id=//p' | sed -e "s/\s/ /g" | cut -d " " -f 1) "Device Enabled" 0

    if [ ! -e $SND_MUTE ]; then
        mute
        touch $SND_MUTE
    fi

    xhost +local:
}

_check_today() {
    local today_check jrnl yesterday journal today
    today=$(date +%Y-%m-%d)
    today_check=$USER_TMP/last.checked.$today
    journal=$USER_TMP/journal.log
    if [ ! -e $today_check ]; then
        yesterday=$(date -d "1 days ago" +%Y-%m-%d)
        jrnl=$(journalctl -p err -q -b -0 --since "$yesterday 00:00:00" | grep -v -E "kernel:|systemd-coredump|^\s" | cut -d " " -f 6- | sort -u)
        if [ ! -z "$jrnl" ]; then
            echo "$jrnl" | sed "s/^/$today: /g" >> $journal
        fi
        touch $today_check
    fi
    if [ -e $journal ]; then
        if [ -s $journal ]; then
            echo
            echo "journal errors"
            echo "=============="
            echo -e "${RED_TEXT}"
            cat $journal | sed "s/^/    /g"
            echo -e "${NORM_TEXT}"
        fi
    fi
    _setup > /dev/null
}
_check_today
