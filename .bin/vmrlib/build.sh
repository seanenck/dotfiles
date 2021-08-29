#!/usr/bin/env bash
machine=$(get_next_machine)
name=$(get_machine_name $machine)
echo "building $machine"
mkdir -p $machine
ip="$(get_ip_from_path $machine):none:$VMR_GATEWAY:$VMR_NETMASK:$name::none:$VMR_DNS"

_build_env() {
    echo "#!/usr/bin/env bash"
    cat <<EOF
IP='$ip'
SSH_KEY='$(cat $VMR_SSH_KEY)'
REPO='$VMR_REMOTE_REPO'
VMLINUZ='$VMR_CURRENT_STORE/$VMR_VMLINUZ'
INITRAMFS='$VMR_CURRENT_STORE/$VMR_INITRAM'
ISO='$VMR_CURRENT_STORE/$VMR_BOOT_ISO'
ROOT='$machine'
EOF
    cat $VMRLIB/lib.start.sh
}

start_sh=$machine/$VMR_START_SH
_build_env > $start_sh
chmod u+x $start_sh
echo $name > $machine/$VMR_NAME_SH
