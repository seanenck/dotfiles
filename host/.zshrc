autoload -Uz compinit
compinit
path+=("$HOME/.local/bin")
export PATH

if [ -d ~/.workdir ]; then
  rsync -c ~/.ssh/config ~/.workdir/host/dev/ssh.config
fi
if [ ! -z "$SSH_CONNECTION" ] && [[ "$TERM" == "xterm-kitty" ]]; then
  export TERM=xterm
fi

function vm() {
  local name
  if [ -z "$1" ]; then
    echo "command required"
    return
  fi
  name="vfu-vm"
  if screen -list | grep -q "$name"; then
    if [[ "$1" == "status" ]]; then
      echo running
    fi
    return
  fi 
  if [[ "$1" == "status" ]]; then
    echo stopped
    return
  fi
  if [[ "$1" == "start" ]]; then
    screen -d -S "$name" -m vm-manager
    return
  fi
  echo "unknown command"
}
