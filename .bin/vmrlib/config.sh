#!/usr/bin/env bash
mkdir -p $VMR_STORE_RESOURCES
mkdir -p $VMR_CURRENT_STORE

_need_download() {
    local f
    for f in $VMR_BOOT_ISO $VMR_VMLINUZ $VMR_INITRAM; do
        if [ ! -e $VMR_CURRENT_STORE/$f ]; then
            echo "yes"
            return
        fi
    done
    echo "no"
}

_iso() {
    local unpack file
    cd $VMRLIB
    unpack=$VMR_CURRENT_STORE/unpack
    rm -rf $unpack
    mkdir -p $unpack
    go get
    go run iso.go $VMR_CURRENT_STORE/$VMR_BOOT_ISO $unpack
    cp $unpack/boot/vmlinuz_lts. $VMR_CURRENT_STORE/$VMR_VMLINUZ.gz
    cp $unpack/boot/initramfs_lts. $VMR_CURRENT_STORE/$VMR_INITRAM
    cd $VMR_CURRENT_STORE
    gzip -d $VMR_CURRENT_STORE/*.gz
    rm -rf $unpack
}

if [[ "$(_need_download)" == "no" ]]; then
    exit
fi
echo "downloading store files"
cd $VMR_CURRENT_STORE
curl -L "$VMR_ISO_URL" > $VMR_BOOT_ISO
_iso
