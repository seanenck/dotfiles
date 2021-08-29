
MEMORY=2048
DISK=1

STORAGE="$ROOT/storage.img"
if [ ! -e $STORAGE ]; then
    dd if=/dev/zero of=$STORAGE bs=1G count=$DISK
fi


PARAMS="ip=$IP ssh_key=\"$SSH_KEY\" alpine_repo=$REPO"

vftool \
    -m $MEMORY \
    -k $VMLINUZ \
    -i $INITRAMFS \
    -d $ISO \
    -d $STORAGE \
    -t 0 \
    -a "console=hvc0 modules=loop,squashfs,virtio $PARAMS" &

vftool_pid=$!
echo "vftool started $vftool_pid"

while [ 1 -eq 1 ]; do
    sleep 1
    ps -p $vftool_pid > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "vftools closed, exiting"
        break
    fi
done
