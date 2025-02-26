autoload -Uz compinit && compinit
comps="$HOME/.local/share/zsh-completion/completions"
if [ -d "$comps" ]; then
  for file in "$comps/"*; do
    source "$file"
  done
fi

[ -d "$HOME/.local/bin" ] && path=("$HOME/.local/bin" $path)

export SECRET_ROOT="$HOME/Library/com.ttypty/secrets"
"$HOME/.local/libexec/update-secrets"
export LOCKBOX_CONFIG_TOML="$SECRET_ROOT/configs/darwin.toml"

transcode-media() {
  "$HOME/.local/libexec/transcode-media"
}

vfu() {
  "$HOME/.local/libexec/vfu" $@
}
