#!/bin/sh
SCAN="$TASK_DOCS"
ARCHIVE="$SCAN/workdir/repositories/"
REPOS="$GIT_SOURCES/private"
LOGS="$TASK_LOGS"
YEAR="$(date +%Y)"
BASE="-01-01 12:00:00 UTC"
CACHE="$TASK_CACHE/checks"
DONE="$CACHE/$(date +%Y.%m.%d)"
PATTERNS="$TASK_VAR/checks/file.patterns"

mkdir -p "$CACHE" "$(dirname "$PATTERNS")"
if [ -e "$DONE" ]; then
  echo "checks already completed"
  exit 0
fi
find "$CACHE" -type f -delete

{
  # bundle validity
  for DIR in "$REPOS/"*; do
    BNAME=$(basename "$DIR")
    BUNDLE="${ARCHIVE}$BNAME.bundle"
    if [ ! -s "$BUNDLE" ]; then
      echo "$BNAME has no bundle (missing $BUNDLE)"
      continue
    fi
    LAST=$(stat -c "%y" "$BUNDLE" | cut -d "." -f 1)
    LAST=$(date -d "$LAST" +%s)
    DT=$(find "$DIR" -type f ! -wholename "*hooks/*" -printf "%TY-%Tm-%Td %TH:%TM:%TS\n" | sort -r | head -n 1)
    DT=$(date -d "$DT" +%s)
    if [ "$LAST" -lt "$DT" ]; then
      echo "$BNAME bundle is out of date"
    fi
  done

  # valid files
  find "$SCAN" -type f | rg -P '[^\x00-\x7f]' | sed 's/^/non-ascii: /g'
  find "$SCAN" -type f | grep -i -E '\.(zip|rar|thumbs.db)$' | sed 's/^/invalid extension: /g'
  if [ "$(find $SCAN -type f -name "* *" | grep -c -v music)" -gt 0 ]; then
    echo "spaces: $cnt (files)"
  fi
  
  # filing structure
  {
    DT=$(date -d "$YEAR$BASE" +%s)
    while : ; do
      NEXTYEAR=$(date -d "1970$BASE + $DT seconds" +"%Y-%m-%d")
      if [ "$(echo "$NEXTYEAR" | cut -d "-" -f 1)" -ne "$YEAR" ]; then
        break
      fi
      MONTH=$(echo "$NEXTYEAR" | cut -d "-" -f 2)
      DAY=$(echo "$NEXTYEAR" | cut -d "-" -f 3)
      for CHR in  "." "/" "-"; do
        for SPACER in "/" "-"; do
          echo "/$MONTH$SPACER$DAY$CHR"
        done
      done
      DT=$((DT+86400))
    done
  } > "$PATTERNS"
  find "$SCAN" -type f | grep "/$YEAR" | grep -v -q -F -f "$PATTERNS" | sed 's#^#invalid file, bad year/month/day sorting: ##g'
  if [ "$(find "$SCAN" -empty | wc -l)" -gt 0 ]; then
    echo "empty files/dirs"
  fi

  # log failures
  for FILE in $(find "$LOGS" -type f -mmin -2160); do
    grep "FAILURE" "$FILE" | sed "s#^#$(basename $FILE): #g"
  done
} > "$DONE"
if [ ! -s "$DONE" ]; then
  echo "system: ok" > "$DONE"
fi
if ! cp "$DONE" "$SYSIM/status"; then
  echo "[FAILURE] unable to send status (retry later)"
  rm -f "$DONE"
fi
