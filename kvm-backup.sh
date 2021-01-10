#!/bin/bash

vms_backupenabled=()
folder=$(date +"%d.%m.%y-%H-%M")
path=/var/lib/libvirt/images/backup/$folder

mkdir -p $path

for vm in "${vms_backupenabled[@]}"; do
	echo "Issuing fstrim command for VM $vm"
	virsh domfstrim "$vm" || true
	sleep 10
	
	# Shut vm down for clean backup
  	echo "Shutting down VM $vm"
  	virsh shutdown "$vm" || true
  	sleep 10

	# Extract VM Domain Config
  	echo "Extracting $vm domain config"
  	virsh dumpxml "$vm" --security-info > $path/$vm.xml

	# Extract VM Storage 
  	echo "Extracting $vm storage"
  	virsh vol-download --sparse --pool default "vm-$vm" $path/_$vm.qcow2

	#  echo "Starting VM $vm"
  	virsh start "$vm"
	echo "Sparsify qcow2 file"
	qemu-img convert -f qcow2 $path/_$vm.qcow2 -O qcow2 $path/$vm.backup.qcow2
	
	# Delete tmp Image
	rm -rf $path/_$vm.qcow2
done
