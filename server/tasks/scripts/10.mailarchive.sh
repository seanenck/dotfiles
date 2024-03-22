#!/bin/sh
MAIL_ROOT="$TASK_CACHE/inbox/Filed"
ARCHIVE="$TASK_DOCS/filing"

YEAR=$(date +%Y)
for FILE in $(find "$MAIL_ROOT/Current/cur/" -type f -mtime -90); do
  SUBJ=$(grep -h -E '^(subject|Subject):' "$FILE" | cut -d ":" -f 2- | head -n 1)
  if [ -z "$SUBJ" ]; then
    SUBJ="no subject in $FILE"
  fi
  DT=$(grep -h -E '^(Date|date):' "$FILE" | cut -d ":" -f 2- | head -n 1)
  PARSED=$(date -d "$DT" +%m-%d-%H-%M-%S)
  if [ -z "$PARSED" ]; then
    echo "[FAILURE] invalid date in email: $FILE"
    continue
  fi
  SUBJ=$(echo "$SUBJ" | sed 's/ /-/'g | tr -cd '[:alnum:]-' | tr '[:upper:]' '[:lower:]')
  while echo "$SUBJ" | grep -q "\--"; do
    SUBJ=$(echo "$SUBJ" | sed 's/\-\-/-/g')
  done
  SUBJ=$(echo "$SUBJ" | sed 's/^-//g' | sed 's/-$//g' | cut -c 1-50)
  HASH=$(sha256sum "$FILE" | cut -c 1-7)
  TARGET="$ARCHIVE/$YEAR/email"
  mkdir -p "$TARGET"
  TARGET="$TARGET/$PARSED.$SUBJ.$HASH.msg"
  if [ -e "$TARGET" ]; then
    # same message could result if hash and all other identifiers are...the same somehow
    continue
  fi
  echo "filing: $FILE -> $TARGET"
  if ! cp "$FILE" "$TARGET"; then
    echo "[FAILURE] unable to archive $FILE"
  fi
done 
