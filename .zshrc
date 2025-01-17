autoload -Uz compinit && compinit
comps="$HOME/.local/share/zsh-completion/completions"
if [ -d "$comps" ]; then
  for file in "$comps/"*; do
    source "$file"
  done
fi

[ -d "$HOME/.local/bin" ] && path=("$HOME/.local/bin" $path)
export TERMINAL_EMULATOR="kitty"

export SECRET_ROOT="$HOME/Library/com.ttypty/secrets"
"$HOME/.local/libexec/update-secrets"
[ -s "$SECRET_ROOT/secrets.env" ] && source "$SECRET_ROOT/secrets.env" && export SECRETS_ENV_FILE="$SECRET_ROOT/secrets.env"
export CFG_LB="darwin"

transcode-media() {
  "$HOME/.local/libexec/transcode-media"
}

vfu() {
  "$HOME/.local/libexec/vfu" $@
}

command -v dotfiles >/dev/null && dotfiles --check
