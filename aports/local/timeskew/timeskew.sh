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
    lt=$(date +%s)
    rt=$(curl --silent "http://router.voidedtech.com/time")
    sleep 10
    delta=0
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
