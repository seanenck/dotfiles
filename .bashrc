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

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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

source $HOME/.bin/common
if [ -e "$EPIPHYTE_CONF" ]; then
    source $EPIPHYTE_CONF
fi
if [ -e "$PRIV_CONF" ]; then
    source $PRIV_CONF
fi
process-pass-aliases
set-system
set-user-files

# ssh agent
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket" 
echo $SSH_AUTH_SOCK > $SSH_AUTH_TMP

# chroot
CHROOT=$CHROOT_LOCATION
export CHROOT

if [ ! -e $BASH_NEW_HIST ]; then
    python -c "
import operator
with open('$BASH_HISTORY') as f:
    lines = [x.strip() for x in f.readlines()]
    cur = {}
    idx = 0
    for l in lines:
        cur[l] = idx
        idx = idx + 1
    vals = sorted(cur.items(), key=operator.itemgetter(1))
    with open('$BASH_NEW_HIST', 'w') as w:
        for l in vals:
            w.write(l[0])
            w.write('\n')
"
    cp $BASH_NEW_HIST $BASH_HISTORY
fi

clear
git-changes
ssh-add -L >/dev/null
if [ $? -ne 0 ]; then
    echo
    echo -e "${RED_TEXT}keys not loaded${NORM_TEXT}"
fi
export GPG_TTY=$(tty)
today_check=$USER_TMP/last.checked.$(date +%Y-%m-%d)
rm -f $today_check
if [ ! -e $today_check ]; then
    process-logs
    touch $today_check
fi
check-timed-events
