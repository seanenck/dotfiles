path+=("$HOME/.local/bin")
export PATH

autoload -Uz compinit && compinit
for file in $HOME/.config/shellrc/*; do
  source "$file"
done

caffeinate manage-data tasks
