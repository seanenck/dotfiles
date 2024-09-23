path+=("$HOME/.local/bin")
export PATH

autoload -Uz compinit && compinit
if [ -d "$HOME/.config/shellrc" ]; then
  for file in $HOME/.config/shellrc/*; do
    source "$file"
  done
fi

manage-data tasks
