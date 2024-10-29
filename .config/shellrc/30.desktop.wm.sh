#!/bin/sh
DIR="$HOME/.local/share/applications/"
if [ -d "$DIR" ]; then
  desktopentry() {
    usage="<name> <app> <type> (<cmd>)"
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
      echo "$usage"
      return
    fi
    file="$DIR/$2.desktop"
    if [ -e "$file" ]; then
      return
    fi
    {
    cat << EOF
[Desktop Entry]
Version=1.0
Name=$1
GenericName=$3: $2
Comment=$3 $2 ($1)
Exec=$4 $2
Terminal=false
Type=Application
EOF
    } > "$file"
  }
  if command -v flatpak >/dev/null; then
    for APP in $(flatpak list --columns app --app | tail -n +1); do
      NAME=$(echo "$APP" | rev | cut -d "." -f 1 | rev)
      desktopentry "$NAME" "$APP" "flatpak" "flatpak run"
    done
  fi
  if [ -e "$TERMINAL_FILE" ]; then
    desktopentry "terminal" "$(cat "$TERMINAL_FILE")" "terminal"
  fi
  unset NAME APP
fi
unset DIR
