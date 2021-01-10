#!/bin/bash

sudo virsh net-destroy default
sudo virsh net-undefine default
range=0
echo "<network>
  <name>default</name>
  <uuid>c89bbc51-de6a-4db4-ac75-b2f3d5692bc6</uuid>
  <forward mode='nat'/>
  <bridge name='virtualBridge0' stp='on' delay='0'/>
  <mac address='52:54:53:00:00:00'/>
  <ip address='10.10.$range.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.10.$range.100' end='10.10.$range.254'/>
    </dhcp>
  </ip>
</network>" > default.xml
sudo virsh net-define default.xml
sudo virsh net-start default

for i in {3..100}; do
  machex=$(printf "%02X" $i)
  echo "update mark-$i -> 52:54:53:00:00:$machex -> 10.10.$range.$i"
  sudo virsh net-update default add ip-dhcp-host \
     --xml "<host mac='52:54:53:00:00:$machex' name='mark-$i' ip='10.10.$range.$i' />" \
     --live --config
done
sudo virsh net-update default add ip-dhcp-host \
     --xml "<host mac='52:54:53:00:00:02' name='mark_template' ip='10.10.$range.2' />" \
     --live --config

sudo virsh net-autostart default
sudo virsh net-list --all