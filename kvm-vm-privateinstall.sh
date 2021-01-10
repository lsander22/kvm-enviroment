#!/bin/bash
[ "$1" == "" ] && {
  echo "usage: $(basename $0) vmid"
  exit 1
}
if [[ -n "$SUDO_USER" ]]; then
   echo "Error: Please run this script not via sudo."
   exit 1
fi

num=$1
hex=$(printf %02X $num)
name=mark-$num
ip=192.168.122.$num

source /usr/local/bin/_kvm-utils.sh

export TIMEFORMAT=%3R

destroy-and-undefine $name

sudo virsh vol-clone --pool default image-mark vm-$name

sudo virt-install \
	--name $name \
	--ram $((2*1024)) \
       	--vcpus=1 \
	--cpu host \
	--controller=scsi,model=virtio-scsi \
	--disk vol=default/vm-$name,bus=scsi,discard=unmap,io=native,cache=none \
	--graphic none \
	--os-type linux \
	--os-variant debian10 \
       	--virt-type kvm \
	--network network=default,mac=52:54:00:e9:f0:$hex,model=virtio \
        --channel unix,target_type=virtio,name=org.qemu.guest_agent.0 \
	--noautoconsole \
	--import \
	--print-xml | tee $name.xml|sudo virsh define /dev/stdin

sudo virt-customize \
       	-d $name \
	--hostname $name \
	--root-password file:/home/lsakvm/rootpw \
	--ssh-inject root:file:/home/lsakvm/id_rsa.pub \
	--edit "/etc/hosts:s/127\.0\.0\.1.*/127.0.0.1 localhost $name/" \
	--run /usr/local/bin/_kvm_initvm.sh
echo customized


sudo virsh start $name
wait-until-ping-and-ssh $ip
