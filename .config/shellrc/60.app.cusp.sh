#!/bin/sh
if [ "$HOST_OS" = "cusp" ]; then
  GUESTOS="$HOME/Env/guestos/cusp"
  # generate abuild.conf (if needed)
  ABUILD="$HOME/.abuild"
  if [ -d "$ABUILD" ]; then
    CONF="$ABUILD/abuild.conf"
    if [ ! -e "$CONF" ]; then
      KEY=$(ls "$ABUILD" | grep '\.rsa$' | grep "dev")
      ROOT_PACKAGES="$GUESTOS/packages"
      {
        echo "# generated file: $(date +%Y-%m-%dT%H:%M:%S)"
        cat << EOF
PACKAGER="Sean Enck <sean@ttypty.com>"
REPOROOT="$ROOT_PACKAGES"
REPODEST="$ROOT_PACKAGES/cusp/next"
EOF
        if [ -n "$KEY" ]; then
          echo PACKAGER_PRIVKEY="$ABUILD/$KEY"
        fi 
      } > "$CONF"
    fi
    unset CONF KEY ROOT_PACKAGES
  fi
  unset ABUILD

  # backup apkovl
  NAME="dev.apkovl.tar.gz"
  MEDIA="/media/apkovl/$NAME"
  BACKUP_TO="$GUESTOS/$NAME"
  if [ -e "$MEDIA" ]; then
    if [ -e "$BACKUP_TO" ]; then
      if [ "$(find "$MEDIA" -type f -newer "$BACKUP_TO" | wc -l)" -eq 0 ]; then
        return
      fi
    fi
    cp "$MEDIA" "$BACKUP_TO"
  fi
fi
