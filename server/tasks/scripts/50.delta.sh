#!/bin/sh
STORE="$TASK_DOCS"
CACHE=$TASK_CACHE/delta/
mkdir -p "$CACHE"

if ! voidedtech-is-report; then
  exit 0
fi

{
  date +%Y-%m-%d
  echo "==="
  CURR=${CACHE}current
  PREV=$CURR.prev
  touch "$CURR" "$PREV"
  find "$STORE" -type f ! -name "*.DS_Store*" ! -wholename "$STORE/synced/*" -exec sha256sum {} \; | sed 's/ /\|/' | awk -F'|' '{print $2" ("substr($1, 0, 7)")"}' | sed "s#^ $STORE/##g" > "$CURR"
  for FILE in $PREV $CURR; do
    if ! sort -o "$FILE" "$FILE"; then
      echo "[FAILURE] unable to cleanup delta file: $FILE"
      exit 1
    fi
  done
  diff -U 0 "$PREV" "$CURR"
  mv "$CURR" "$PREV"
} > "$TASK_REPORTS/delta"
