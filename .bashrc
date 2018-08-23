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

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx $HOME/.xinitrc
  return
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
    source /usr/share/bash-completion/completions/pass
    for i in $(echo "$PASS_ALIASES"); do
        alias pass-$i="PASSWORD_STORE_DIR=${PERM_LOCATION}pass-$i pass"
        eval '_pc_'$i'() { PASSWORD_STORE_DIR='${PERM_LOCATION}'pass-'$i'/ _pass; }'
        complete -o filenames -o nospace -F _pc_$i pass-$i
    done
    alias totp="_totpall $TOTP_PASS \$@"
    for i in $(echo "$LUKS_REMOTE"); do
        alias luks-$i="enterkeys luks-$i"
    done
fi

# sbh implementation
function _history-tree()
{
    source $HOME/.bin/sbh
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
systemctl start --user status.service
if [ -e $GIT_CHANGES ]; then
    cat $GIT_CHANGES 2>/dev/null
    rm -f $GIT_CHANGES
fi

_setup() {
    if [ ! -e $SND_MUTE ]; then
        mute
        touch $SND_MUTE
    fi

    xhost +local:
}

_check_today() {
    local today_check jrnl yesterday journal today yest since filename ifs
    today=$(date +%Y-%m-%d)
    filename=$USER_TMP/last.checked.
    today_check=$filename$today
    journal=$USER_JOURNAL
    if [ ! -e $today_check ]; then
        yesterday=$(date -d "1 days ago" +%Y-%m-%d)
        yest=$filename$yesterday
        since="$yesterday 00:00:00"
        if [ -e $yest ]; then
            since=$(cat $yest)
        fi
        jrnl=$(journalctl -p err -q -b -0 --since "$since" | grep -v -E "kernel:|systemd-coredump|^\s" | cut -d " " -f 6- | sort -u)
        if [ ! -z "$jrnl" ]; then
            echo "$today (since $since):" >> $journal
            echo "$jrnl" >> $journal
            echo "" >> $journal
        fi
        date +"%Y-%m-%d %H:%M:%S" > $today_check
    fi
    if [ -e $journal ]; then
        if [ -s $journal ]; then
            ifs=$IFS
            IFS=$'\n'
            for l in $(cat $journal | tail -n +2); do
                notify-send --urgency=critical Journal "$l"
            done
            IFS=$ifs
        fi
    fi
    _setup > /dev/null
}
_check_today
