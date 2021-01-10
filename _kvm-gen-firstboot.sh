IFACE=enp1s0
interfaces="source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto $IFACE
iface $IFACE inet dhcp
"
aptsources="
deb http://ftp.hosteurope.de/mirror/ftp.debian.org/debian/ testing contrib non-free main
deb-src http://ftp.hosteurope.de/mirror/ftp.debian.org/debian/ testing contrib non-free main
deb http://ftp.hosteurope.de/mirror/ftp.debian.org/debian/ testing-updates non-free contrib main
deb-src http://ftp.hosteurope.de/mirror/ftp.debian.org/debian/ testing-updates non-free contrib main
"

echo "#!/bin/bash
IFACE=enp1s0
date +'%Y-%m-%d %H:%M:%S'
timedatectl set-timezone Europe/Berlin
hostnamectl set-hostname debianbase

echo '$interfaces' > /etc/network/interfaces
systemctl restart networking



echo de_DE.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo 'LANG=\"en_US.UTF-8\"'>/etc/default/locale
dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG=en_US.UTF-8


dpkg-reconfigure --frontend=noninteractive openssh-server
echo '$aptsources' >/etc/apt/sources.list

export DEBIAN_FRONTEND=noninteractive
apt update -y
apt dist-upgrade -y
apt-get install -y vim htop sudo curl net-tools bridge-utils qemu-guest-agent
touch /root/.hushlogin
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/g' /etc/default/grub
/usr/sbin/update-grub
update-alternatives --set editor /usr/bin/vim.basic
lsb_release -a
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
sed -i 's/^#NTP=/NTP=194.94.217.126/g' /etc/systemd/timesyncd.conf
systemctl restart systemd-timesyncd
fstrim -av

systemctl reload ssh
systemctl poweroff

" >./firstboot.sh
chmod +x firstboot.sh
