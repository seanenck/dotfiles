autoload -Uz compinit
compinit
path+=("$HOME/.local/bin")
export PATH

if [ ! -z "$SSH_CONNECTION" ] && [[ "$TERM" == "xterm-kitty" ]]; then
  export TERM=xterm
fi
