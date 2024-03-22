#!/bin/sh
CACHES="$TASK_VAR"
CLONE_NAME="git.tasks"
REPORT="$TASK_REPORTS/git"
export HOME="$TASK_VAR"

if voidedtech-is-report; then
  {
    date +%Y-%m-%d 
    echo
  } > "$REPORT"
fi

for REPO in books dav; do
  echo "handling: $REPO"
  DIR="$CACHES/$CLONE_NAME"
  SOURCES="$GIT_SOURCES/private/$REPO.git"
  rm -rf "$DIR"
  if ! (cd "$CACHES" && git clone "$SOURCES" "$CLONE_NAME"); then
    echo "[FAILURE] unable to clone: $REPO"
    continue
  fi
  {
    cat << EOF
[core]
  autocrlf = false
[user]
  email = automated@localhost
  name = automated
EOF
  } >> "$DIR/.git/config"
  for TRY in $(seq 0 2); do
    if ! (cd "$DIR/" && ./configure); then
      echo "[FAILURE] unable to update: $REPO (try: $TRY)"
      sleep 60
      continue
    fi
    break
  done
  if voidedtech-is-report; then
    {
      echo
      echo "$REPO"
      echo "==="
      git -C "$DIR" log --since=@{7.days.ago} --format=%H --stat --name-only 2>&1 | \
        grep '^[a-z0-9]' | \
        grep '/' | \
        grep -v "^raw/" | \
        grep -v "^etc/" | \
        sort -u
    } >> "$REPORT"
  fi
done
