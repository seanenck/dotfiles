#!/usr/bin/env bash
PIDFILE="/run/timeskew.pid"

_log() {
  echo "$@" | logger -t timeskew
}

_datetime() {
  date | cut -d " " -f 2- | rev | cut -d " " -f 3- | rev
}

_daemon() {
  local dt pid cur reset h login
  dt=$(_datetime)
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
    sleep 1
    reset=0
    if awk "\$0>=\"$dt\"" < /var/log/messages | grep -q "WARNING: clock skew detected"; then
      _log "potentially skewed time"
      reset=1
    fi
    for h in /home/*; do
      login="$h/.cache/login"
      if [ -e "$login" ]; then
        _log "user login detected: $login"
        rm -f "$login"
        reset=1
      fi
    done
    if [ "$reset" -eq 1 ]; then
      _log "restarting chrony"
      pkill chronyd 2>&1 | logger -t timeskew
      if ! rc-service chronyd restart 2>&1 | logger -t timeskew; then
        continue
      fi
    fi
    dt=$(_datetime)
  done
}

_daemon &
