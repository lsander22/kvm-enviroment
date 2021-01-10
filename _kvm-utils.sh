#!/bin/bash
function destroy-and-undefine {
  sudo virsh destroy "$1" 2>/dev/null
  sudo virsh undefine "$1" 2>/dev/null
  sudo virsh vol-delete --pool default vm-$1 2>/dev/null
}

function wait-until-ping-and-ssh {
  echo "wait for ping"
  while ! ping -W 1 -q -c 1 "$1" &>/dev/null; do echo -n .; sleep 1; done
  echo
  echo "wait for ssh-server start"
  while ! ssh-keyscan -t rsa -H "$1" 2>/dev/null | grep -q .; do
	echo -n .
        sleep 1
  done
  echo
  echo "remove former hostkey"
  sudo -u lsakvm ssh-keygen -q -R "$1" &>/dev/null

  echo "get key and add to known_hosts"
  ssh-keyscan -t rsa -H "$1" 2>/dev/null \
	| sudo -u lsakvm tee -a /home/lsakvm/.ssh/known_hosts >/dev/null
  sudo -u lsakvm ssh root@"$1" hostname
}
