autoload -Uz compinit && compinit
comps="$HOME/.local/share/zsh-completion/completions"
if [ -d "$comps" ]; then
  for file in "$comps/"*; do
    source "$file"
  done
fi

[ -d "$HOME/.local/bin" ] && path=("$HOME/.local/bin" $path)
[ -d "$HOME/Env/wac" ] && path=("$HOME/Env/wac/target/bin" $path) && (manage-data &)
export TERMINAL_EMULATOR="kitty"

[ -s "$HOME/Env/secrets/secrets.env" ] && source "$HOME/Env/secrets/secrets.env" && export SECRETS_ENV_FILE="$HOME/Env/secrets/secrets.env"
export CFG_LB="darwin"

transcode-media() {
  local file ext dt hashed tmpl
  for file in *.*; do
    ext=$(basename "$file" | rev | cut -d "." -f 1 | rev | tr '[:upper:]' '[:lower:]')
    dt=$(date +"%d.T_%H%M%S")
    hashed=$(shasum -a 256 "$file" | cut -c 1-7)
    tmpl="$dt.$hashed."
    echo "processing: $file (-> $tmpl)"
    case "$ext" in
      "jpeg" | "jpg" | "mov")
        mv "$file" "$tmpl$ext"
        ;;
      "heic")
        tmpl="${tmpl}jpeg"
        sips --setProperty format jpeg --out "${tmpl}" "$file"
        if [ -e "$tmpl" ]; then
          rm -f "$file"
        fi
        ;;
    esac
  done
}

vfu() {
  local ext configs startcmd statuscmd file matched name screen
  ext="\.json"
  configs="$HOME/.config/vfu/"
  startcmd="start"
  statuscmd="status"
  [ -z "$1" ] && echo "command required" && return
  if [ "$1" = "completions" ]; then    
    cat << EOF
#compdef _vfu vfu

_vfu() {
  local curcontext="\$curcontext" state len chosen found args
  typeset -A opt_args

  _arguments \
    '1: :->main'\
    '*: :->args'

  len=\${#words[@]}
  case \$state in
    main)
      args="$startcmd $statuscmd"
      _arguments "1:main:(\$args)"
      ;;
    *)
      if [ "\$len" -ne 3 ]; then
        return
      fi
      chosen=\$words[2]
      if [ "\$chosen" = "$startcmd" ]; then
        compadd \$@ \$(ls "$configs" | grep "$ext" | cut -d "." -f 1)
      fi
      ;;
  esac
}

compdef _vfu vfu
EOF
    return
  fi
      
  matched=0
  for file in $(ls "$configs" | grep "$ext"); do
    name="$(basename "$file" | cut -d "." -f 1)"
    screen="vfu-vm-$name"
    case "$1" in
      "$statuscmd")
        if [ "$matched" -eq 0 ]; then
          printf "%-10s %s\n------------------\n" "vm" "status"
        fi
        matched=1
        printf "%-10s " "$name"
        if screen -list 2>/dev/null | grep -q "$screen"; then
          printf "running"
        else
          printf "stopped"
        fi
        echo
        ;;
      "$startcmd")
        if [ -n "$2" ] && [ "$2" = "$name" ]; then
          screen -d -m -S "$screen" /Applications/vfu.app/Contents/MacOS/vfu-cli --config "$configs/$file"
          matched=1
          break
        fi
        ;;
    esac
  done
  
  [ "$matched" -eq 1 ] && return
  
  echo "invalid command"
  echo
  echo "vfu [$startcmd|$statuscmd] <vm?>"
}

command -v dotfiles >/dev/null && dotfiles --check
command -v manage-data >/dev/null && manage-data motd
