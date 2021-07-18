LOGFILE=container.log
_httpserver() {
  python3 -m http.server $HTTPPORT --bind 0.0.0.0
}

_httpserver &
sleep 1

PARAMS="ssh_key=$SSHKEYS"
PARAMS="$PARAMS ip=$IP"
PARAMS="$PARAMS apkovl=http://192.168.64.1:$HTTPPORT/macvm.apkovl.tar.gz"
PARAMS="$PARAMS alpine_repo=$REPO"

_vftool() {
    vftool \
      -m $MEMORY \
      -k vmlinuz-lts \
      -i initramfs-lts \
      -d $ISO \
      -a "console=hvc0 modules=loop,squashfs,virtio $PARAMS" 2>&1 | tee $LOGFILE
}

cat $LOGFILE >> log.$(date +%Y-%m-%d)
rm -f $LOGFILE
_vftool &

while [ 1 -eq 1 ]; do
    echo "waiting for attach"
    sleep 1
    dev=$(cat $LOGFILE | grep "Waiting for connection to" | rev | cut -d ":" -f 1 | rev | sed 's/\s*//g')
    if [ -z "$dev" ]; then
        continue
    fi
    screen $dev
    break
done
