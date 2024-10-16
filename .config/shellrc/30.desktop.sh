#!/bin/sh
if command -v flatpak >/dev/null; then
  for APP in $(flatpak list --columns app --app | tail -n +1); do
    NAME=$(echo "$APP" | rev | cut -d "." -f 1 | rev)
    {
      cat << EOF
[Desktop Entry]
Version=1.0
Name=$NAME
GenericName=flatpak: $APP
Comment=flatpak $APP ($NAME)
Exec=flatpak run $APP
Terminal=false
Type=Application
EOF
    } > "$HOME/.local/share/applications/$APP.desktop"
  done
fi
