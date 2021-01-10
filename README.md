# kvm-enviroment
This is my attempt to build a virtualised infrastructure with libvirtd.

# Install 

My server is currently running a Fedora system. The scripts were adapted for this system.

```bash
git clone https://github.com/lsander22/kvm-enviroment.git
```

```bash
cd kvm-enviroment/
cp *-sh /usr/local/bin
sudo chmod u+x /usr/local/bin
```

I created a user to log on to all new vms without a password. The ssh key of this user is then stored on the machines. There is also a file with the default root password.

```bash
sudo adduser lsakvm
sudo -i -u lsakvm
ssh-keygen 
cp .ssh/id_rsa.pub ./
touch rootpw && echo "<rootpw>" > rootpw
```

It is time to run the installation scripts.
* ```kvm-install.sh``` installs all the necessary packages for libvirtd and virsh.
* ```kvm-storage-create-pool.sh``` Creates the storage pool for the virtual machines
* ```kvm-net-setup.sh``` Creates default network for the new virtual machines
* ```kvm-image-createdebian.sh``` Creates a current Debian image from which the machines are later cloned. This speeds up the VM creation massively 
* ```kvm-vm-privateinstall.sh``` Installs a Debian VM according to the Iron Man naming scheme mark-<num>.
* ```kvm-vm-privatewithname.sh```Creates a Debian VM with a specific size, name and IP address.
*

```bash
# You need to be your normal non-root user in your home directory
cd
kvm-install.sh
kvm-storage-create-pool.sh
kvm-net-setup.sh
kvm-image-createdebian.sh
kvm-vm-privateinstall.sh
```

I have also created a first version of a backup script.
Simply insert the vms to be backed up into the array at the top of kvm-backup.sh.

Have fun with the scripts. I am open for questions or any problems that might occur. Just send me a message.

