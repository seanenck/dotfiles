LOGFILE=container.log
_httpserver() {
    local pid
    pid=$(ps aux | grep "http.server" | grep $HTTPPORT | grep -v "grep " | grep -v "rg " | awk '{print $2}')
    if [ ! -z "$pid" ]; then
        echo "killing old server $pid"
        kill -9 $pid
    fi
    python3 -m http.server $HTTPPORT --bind 0.0.0.0
}

_httpserver &
sleep 1

PARAMS="ssh_key=$SSHKEYS"
PARAMS="$PARAMS ip=$IP"
PARAMS="$PARAMS apkovl=http://192.168.64.1:$HTTPPORT/macvm.apkovl.tar.gz"
PARAMS="$PARAMS alpine_repo=$REPO"

touch $LOGFILE
cat $LOGFILE >> log.$(date +%Y-%m-%d)
rm -f $LOGFILE
touch $LOGFILE

vftool \
    -m $MEMORY \
    -k vmlinuz-lts \
    -i initramfs-lts \
    -d $ISO \
    -a "console=hvc0 modules=loop,squashfs,virtio $PARAMS" >> $LOGFILE 2>&1 &

vftool_pid=$!
echo "vftool started $PID"

while [ 1 -eq 1 ]; do
    echo "waiting for attach..."
    cat $LOGFILE
    sleep 1
    dev=$(cat $LOGFILE | grep "Waiting for connection to" | rev | cut -d ":" -f 1 | rev | sed 's/\s*//g')
    if [ -z "$dev" ]; then
        continue
    fi
    echo "attaching to $dev"
    screen -D -m -S macvm$ID.tty.$HTTPPORT $dev
    break
done

while [ 1 -eq 1 ]; do
    sleep 1
    ps -p $vftool_pid > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "vftools closed, exiting"
        break
    fi
done
