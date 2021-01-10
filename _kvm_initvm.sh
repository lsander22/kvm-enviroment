#!/bin/bash
  date
  rm -v /etc/ssh/ssh_host_*
  ssh-keygen -A
  rm -f /etc/machine-id /var/lib/dbus/machine-id
  dbus-uuidgen --ensure=/etc/machine-id
  rm /var/lib/systemd/random-seed
  #dpkg-reconfigure --frontend=noninteractive openssh-server
