export PATH="$HOME/.bin:$PATH"
export CLICOLOR=1

zstyle ':completion:*:*:git:*' user-commands uncommitted:'check for uncommitted changes' env:'pull env file updates' 
autoload -Uz compinit && compinit
COMPLETIONS="$HOME/.completions"
if [ ! -d "$COMPLETIONS" ]; then
  mkdir -p "$COMPLETIONS"
fi
LB_COMP="$COMPLETIONS/lb"
if [ -x "$HOME/.bin/lb" ]; then
  if [ ! -s "$LB_COMP" ]; then
    lb zsh > "$LB_COMP" 
  fi
fi
for file in $(ls "$COMPLETIONS"); do
  source "$COMPLETIONS/$file"
  compdef _$file $file
done

unset file COMPLETIONS LB_COMP 

export TERM=xterm-256color
alias scp="echo noop"
git uncommitted
