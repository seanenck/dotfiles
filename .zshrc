autoload -Uz compinit && compinit
comps="$HOME/.local/share/zsh-completion/completions"
if [ -d "$comps" ]; then
  for file in "$comps/"*; do
    source "$file"
  done
fi
if [ -d "$HOME/.config/shellrc" ]; then
  for file in "$HOME/.config/shellrc/"*; do
    source "$file"
  done
fi
