#!/bin/bash
#if [[ -n "$SUDO_USER" ]]; then
#   echo "Error: Please run this script not via sudo."
#   exit 1
#fi
/usr/local/bin/_kvm-gen-firstboot.sh

# Cleanup
sudo virsh destroy mark_template 2>/dev/null
sudo virsh undefine mark_template 2>/dev/null
sudo virsh vol-delete --pool default image-mark 2>/dev/null

virt-builder debian-10 --format qcow2 --output mark_template.qcow2
sudo virsh vol-create-as default image-mark 6G --format qcow2
sudo virsh vol-upload --pool default image-mark mark_template.qcow2
sudo rm mark_template.qcow2
sudo virt-install \
	--name mark_template \
	--ram 1024 \
       	--vcpus=2 \
	--disk vol=default/image-mark \
	--graphic none \
	--os-type linux \
	--os-variant debian10 \
       	--virt-type kvm \
	--network network=default,mac=52:54:00:e9:f0:01,model=virtio \
	--noautoconsole \
	--print-xml \
	--import | sudo virsh define /dev/stdin

sudo virt-customize \
	-d mark_template \
	--root-password file:/home/lsakvm/rootpw \
	--firstboot firstboot.sh

sudo virsh start mark_template

while [[ "$(sudo virsh domstate mark_template)" == "running" ]]; do
  sleep 1
  echo -n "."
done
echo

sudo virsh undefine mark_template
