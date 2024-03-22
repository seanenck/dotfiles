#!/bin/sh
CONF="$TASK_SOURCE/rclone.conf"
STORE="$TASK_DOCS"
CACHE="$TASK_CACHE/rclone"
CUR="$CACHE/current.status"
LAST="$CACHE/last.status"

for TRY in $(seq 0 2); do
  if ! rclone sync --modify-window 60s --filter-from="$TASK_SOURCE/rclone.filter" -v "$STORE" enc: -L --config "$CONF"; then
    echo "[FAILURE] rclone 'sync' (try: $TRY)"
    sleep 60
    continue
  fi
  break
done

for TRY in $(seq 0 2); do
  if ! rclone cleanup -v enc: --config "$CONF"; then
    echo "[FAILURE] rclone 'cleanup' (try: $TRY)"
    sleep 60
    continue
  fi
  break
done

if voidedtech-is-report; then
  mkdir -p "$CACHE"
  touch "$CUR" "$LAST"
  {
    echo "date: $(date +%Y-%m-%d)"
    rclone --config "$CONF" lsjson enc: -R | jq -r '.[].ModTime' | sort -r | head -n 1 | cut -d 'T' -f 1 | sed 's/^/modtime: /g'
    rclone --config "$CONF" ls enc: | wc -l | sed 's/^/files: /g'
  } > "$CUR"

  {
    cat "$CUR"
    echo
    cat "$LAST"
  } > "$TASK_REPORTS/rclone"
  mv "$CUR" "$LAST"
fi
