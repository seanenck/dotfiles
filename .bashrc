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

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# colored prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
source $HOME/.config/home/common
if [[ ! $DISPLAY && XDG_VTNR -eq 1 ]]; then
    _init &
	exec startx $HOME/.xinitrc
	return
fi

export VISUAL=vim
export EDITOR="$VISUAL"

source $XDG_USER_CONFIG
export GOPATH=$HOME/.go
export TERM=xterm
DEBEMAIL="enckse@voidedtech.com"
DEBFULLNAME="Sean Enck"
export DEBEMAIL DEBFULLNAME
if [ ! -z "$SCHROOT_CHROOT_NAME" ]; then
    return
fi

if [ -e "$PRIV_CONF" ]; then
    source $PRIV_CONF
    source /usr/share/bash-completion/completions/pass
    for i in $(echo "$PASS_ALIASES"); do
        alias pass-$i="PASSWORD_STORE_DIR=${PERM_LOCATION}pass-$i pass"
        eval '_pc_'$i'() { PASSWORD_STORE_DIR='${PERM_LOCATION}'pass-'$i'/ _pass; }'
        complete -o filenames -o nospace -F _pc_$i pass-$i
    done
    for i in $(echo "$LUKS_ENTRIES"); do
        n=$(echo "$i" | cut -d "/" -f 1)
        alias luks-$n='xwindows $(PASSWORD_STORE_DIR='${PERM_LOCATION}$LUKS_PASS' '$LUKS_PASS' show '$i'/luks 2>&1)'
    done
fi

# ssh agent
# Set SSH to use gpg-agent
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
fi
echo $SSH_AUTH_SOCK > $SSH_AUTH_TMP

# gpg setup
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

if [ -s $GIT_CHANGES ]; then
    cat $GIT_CHANGES 2>/dev/null
fi

if [ ! -e $VIEW_JOURNAL ]; then
    _yesterday=$(date -d "1 day ago" +%Y-%m-%d)
    _today=$(date +%Y-%m-%d)
    echo
    echo -e "journal:$RED_TEXT"
    journalctl -p err --since "$_yesterday 00:00:00" --until "$_today 00:00:00" | cut -d " " -f 5- | tail -n +2 | sed 's/^/    /g'
    echo -e "${NORM_TEXT}clear-journal to suppress"
    echo
fi
