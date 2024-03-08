autoload -Uz compinit
compinit
path+=("$HOME/.local/bin")
export PATH

if [ "$(find ~/Documents/hosted -mtime -7 | wc -l)" -eq 0 ]; then
  echo
  echo "sync"
  echo "===="
  echo "- no recent sync"
  echo
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
