# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

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

# cleanup user temp
mkdir -p $USER_TMP 
date +%Y-%m-%d.%s > $LAST_TMP_HIT
find $USER_TMP* -mtime +1 -type f -exec rm {} \;
find $USER_TMP -empty -type d -delete

# ssh agent
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket" 
echo $SSH_AUTH_SOCK > $SSH_AUTH_TMP

# workspacer
start_workspacer=1
for p in $(pidof python); do
    ps $p | grep -q "i3workspacer"
    if [ $? -eq 0 ]; then
        start_workspacer=0
    fi
done

function nohup-workspace()
{
    nohup workspacer > /tmp/i3workspace.log &
}

if [ $start_workspacer -eq 1 ]; then
    nohup-workspace > /dev/null 2>&1
fi

if [ ! -f $BASH_NEW_HIST ]; then
    awk '!a[$0]++' $BASH_HISTORY > $BASH_NEW_HIST
    cp $BASH_NEW_HIST $BASH_HISTORY
fi

# chroot
CHROOT=$CHROOT_LOCATION
export CHROOT

# touchpad
xinput set-prop $(xinput | grep "SynPS/2" | sed -n -e 's/^.*id=//p' | sed -e "s/\s/ /g" | cut -d " " -f 1) "Device Enabled" 0

clear
git-changes
if [ ! -e $USER_LAST_SYNC ]; then
    echo
    echo -e "${RED_TEXT}no reset sync${NORM_TEXT}"
fi
ssh-add -L >/dev/null
if [ $? -ne 0 ]; then
    echo
    echo -e "${RED_TEXT}keys not loaded${NORM_TEXT}"
fi
export GPG_TTY=$(tty)
check-timed-events
