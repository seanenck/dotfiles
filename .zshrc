autoload -Uz compinit && compinit
source ~/.local/share/zsh-completion/completions/*
if [ -d "$HOME/.config/shellrc" ]; then
  for file in "$HOME/.config/shellrc/"*; do
    source "$file"
  done
fi
