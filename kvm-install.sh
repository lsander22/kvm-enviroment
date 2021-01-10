sudo dnf -y install bridge-utils libvirt virt-install qemu-kvm

for i in {1..5}; do echo "Waiting ... "; sleep 1; done;

sudo dnf -y install virt-top libguestfs-tools
