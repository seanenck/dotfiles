#!/bin/sh
CACHE=$TASK_VAR/sent/
MAIL_DIR=$TASK_CACHE
INBOX="$MAIL_DIR/inbox/INBOX"
FROM_ADDRESS="enckse@voidedtech.com"
TO_ADDRESS="$FROM_ADDRESS"

if [ "$(find "$SYSIM/" -type f | wc -l)" -eq 0 ]; then
  echo "no mail processing request"
  exit 0
fi

echo "processing mail"

mkdir -p "$CACHE"
find "$CACHE" -type f -mtime +2 -delete
for FILE in $(find "$SYSIM/" -type f); do
  NAME=$(basename "$FILE")
  if [ -s "$FILE" ]; then
    MSGID=$(echo "<"$(date +%s).$(sha256sum "$FILE" | cut -c1-10).$(stat -c %y "$FILE" | sha256sum | cut -c1-10)."@voidedtech>")
    MAILFILE=$(echo $(date +%s)"."$$_$(sha256sum "$FILE" | cut -c1-7)".store:2,")
    TMPFILE="$INBOX/tmp/$MAILFILE"
    {
      echo "From: $FROM_ADDRESS"
      echo "To: $TO_ADDRESS"
      echo "Subject: $NAME"
      echo "Message-Id: $MSGID"
      echo "Date: $(date --rfc-email)"
      echo "Content-Type: text/plain"
      echo
      cat "$FILE"
    } > "$TMPFILE"
    if ! mv "$TMPFILE" "$INBOX/new/$MAILFILE"; then
      echo "[FAILURE] unable to deliver message: $FILE"
    fi
    rm -f "$TMPFILE"
  fi
  mv "$FILE" "$CACHE/$NAME.$(date +%Y-%m-%d-%H-%M-%S)"
done

for TRY in $(seq 0 2); do
  if ! (cd "$MAIL_DIR" && HOME=$TASK_VAR mbsync --config "$TASK_SOURCE/mbsync.conf" -a); then
    echo "[FAILURE] mbsync (try: $TRY)"
    sleep 45
    continue
  fi
  break
done
