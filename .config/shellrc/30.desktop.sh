#!/bin/sh
DIR="$HOME/.local/share/applications/"
DESKTOP_FILE=$(
cat << EOF
[Desktop Entry]
Version=1.0
Name={{NAME}}
GenericName={{TYPE}}: {{APP}}
Comment={{TYPE}} {{APP}} ({{NAME}})
Exec={{CMD}} {{APP}}
Terminal=false
Type=Application
EOF
)
if [ -d "$DIR" ]; then
  if command -v flatpak >/dev/null; then
    for APP in $(flatpak list --columns app --app | tail -n +1); do
      NAME=$(echo "$APP" | rev | cut -d "." -f 1 | rev)
      {
        echo "$DESKTOP_FILE" | sed "s/{{APP}}/$APP/g;s/{{NAME}}/$NAME/g;s/{{TYPE}}/flatpak/g;s/{{CMD}}/flatpak run /g"
      } > "$DIR/$APP.desktop"
    done
  fi
  FILE="$HOME/.local/state/terminal"
  if [ -e "$FILE" ]; then
    {
      APP=$(cat "$FILE")
      echo "$DESKTOP_FILE" | sed "s/{{APP}}/$APP/g;s/{{NAME}}/terminal/g;s/{{TYPE}}/terminal/g;s/{{CMD}}//g"
    } > "$DIR/org.localhost.terminal.desktop"
  fi
  unset FILE NAME APP
fi
unset DIR DESKTOP_FILE
