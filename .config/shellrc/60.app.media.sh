#!/usr/bin/env bash
if [ "$(uname)" = "Darwin" ]; then
  transcode-media() {
    for FILE in *.*; do
      EXT=$(basename "$FILE" | rev | cut -d "." -f 1 | rev | tr '[:upper:]' '[:lower:]')
      DATE=$(date +"%d.T_%H%M%S")
      HASH=$(shasum -a 256 "$FILE" | cut -c 1-7)
      TMPL="$DATE.$HASH."
      echo "processing: $FILE (-> $TMPL)"
      case "$EXT" in
        "jpeg" | "jpg" | "mov")
          mv "$FILE" "$TMPL$EXT"
          ;;
        "heic")
          TMPL="${TMPL}jpeg"
          sips --setProperty format jpeg --out "${TMPL}" "$FILE"
          if [ -e "$TMPL" ]; then
            rm -f "$FILE"
          fi
          ;;
      esac
    done
  }
fi
