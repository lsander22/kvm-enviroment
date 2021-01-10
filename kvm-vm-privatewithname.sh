#!/bin/bash
[ "$2" == "" ] && {
  echo "usage: $(basename $0) [SIZE] [NAME] [IP]"
  exit 1
}
if [[ -n "$SUDO_USER" ]]; then
   echo "Error: Please run this script not via sudo."
   exit 1
fi

size=$1
name=$2
ip=$3
mac=$(printf "52:54:%02X:%02X:%02X:%02X\n" ${ip//./ })

source /usr/local/bin/_kvm-utils.sh

destroy-and-undefine $name

sudo virsh vol-clone --pool default image-mark vm-$name

sudo virsh vol-resize \
        --pool default \
        --vol "vm-$name" \
        --capacity "${size}G"

sudo virt-install \
	--name $name \
	--ram $((16*1024)) \
       	--vcpus=8 \
	--cpu host \
	--controller=scsi,model=virtio-scsi \
	--disk vol=default/vm-$name,bus=scsi,discard=unmap,io=native,cache=none \
	--graphic none \
	--os-type linux \
	--os-variant debian10 \
       	--virt-type kvm \
	--network bridge=virbr0,mac=$mac,model=virtio \
        --channel unix,target_type=virtio,name=org.qemu.guest_agent.0 \
	--noautoconsole \
	--import \
	--print-xml | tee $name.xml|sudo virsh define /dev/stdin

sudo guestfish -d "$name" <<_EOF_
 run
 part-resize /dev/sda 1 -1
 resize2fs /dev/sda1
_EOF_

echo "
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto enp1s0
iface enp1s0 inet static
address $ip
netmask 255.255.255.0
gateway 192.168.122.1
dns-nameservers 192.168.122.1 8.8.8.8" > interfaces
echo "
nameserver 192.168.122.1" > resolv.conf

sudo virt-customize \
       	-d $name \
	--hostname $name \
	--root-password file:/home/lsakvm/rootpw \
	--ssh-inject root:file:/home/lsakvm/id_rsa.pub \
	--edit "/etc/hosts:s/127\.0\.0\.1.*/127.0.0.1 localhost $name/" \
	--run /usr/local/bin/_kvm_initvm.sh \
	--copy-in interfaces:/etc/network/ \
	--copy-in resolv.conf:/etc/
echo customized


sudo virsh start $name
wait-until-ping-and-ssh $ip
