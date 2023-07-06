#!/usr/bin/env bash
PIDFILE="/run/timeskew.pid"

_daemon() {
  local pid cur lt rt delta
  pid="$$"
  echo "$pid" > $PIDFILE
  while : ; do
    if [ ! -e "$PIDFILE" ]; then
      return
    fi
    cur=$(cat "$PIDFILE")
    if [ "$cur" != "$pid" ]; then
      return
    fi
    sleep 10
    rt=$(curl --silent "http://router.voidedtech.com/time")
    if [ -n "$rt" ] && [ "$rt" -eq "$rt" ] 2>/dev/null; then
      lt=$(date +%s)
      delta=0
    else
      continue
    fi
    if [ "$lt" -gt "$rt" ]; then
      delta=$((lt-rt))
    else
      if [ "$rt" -gt "$lt" ]; then
        delta=$((rt-lt))
      fi
    fi
    if [ "$delta" -gt 10 ]; then
      {
        echo "delta detected, exceeds threshold: $delta (local: $lt, remote: $rt)"
        pkill chronyd
        rc-service chronyd restart
      } 2>&1 | logger -t timeskew
    fi
  done
}

_daemon &
