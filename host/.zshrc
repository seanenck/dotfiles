path+=("$HOME/.local/bin")
export PATH

autoload -Uz compinit
compinit
comps="$HOME/.local/completions"
if [ -d "$comps" ]; then
  for f in "$comps"/*; do
    source "$f"
  done
fi
if which lb > /dev/null; then
  source "$HOME/.workdir/git/secrets/lockbox.env"
fi

if [ ! -z "$SSH_CONNECTION" ] && [[ "$TERM" == "xterm-kitty" ]]; then
  export TERM=xterm
fi
