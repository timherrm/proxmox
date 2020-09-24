#!/bin/bash
######################################################
#### WARNING PIPING TO BASH IS STUPID: DO NOT USE THIS
######################################################
# modified from: jimangel/ubuntu-18.04-scripts/prepare-ubuntu-18.04-template.sh
# TESTED ON UBUNTU 20.04.1 Server

# SETUP & RUN
# curl -sL https://raw.githubusercontent.com/timherrm/proxmox/master/prep-ubuntu-server-20.04.1-template.sh | sudo -E bash -

if [ `id -u` -ne 0 ]; then
	echo Need sudo
	exit 1
fi

set -v

#update apt-cache
apt update -y
apt dist-upgrade -y

#install packages
apt install qemu-guest-agent vim openssh-server -y

#cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

#cleanup current ssh keys
rm -f /etc/ssh/ssh_host_*

#add check for ssh keys on reboot...regenerate if neccessary
cat << 'EOL' | sudo tee /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
if hostname | grep ubuntu-server-template; then
    hostnamectl set-hostname "$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')"
    systemd-machine-id-setup
fi
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL

# make sure the script is executable
chmod +x /etc/rc.local

#cleanup apt
apt autoremove -y
apt autoclean -y

# disable swap
sudo swapoff --all
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

# cleans out all of the cloud-init cache / logs - this is mainly cleaning out networking info
sudo cloud-init clean --logs

#extend filesystem
lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
resize2fs -p /dev/mapper/ubuntu--vg-ubuntu--lv

#reset machine id
rm /etc/machine-id

#cleanup shell history
cat /dev/null > ~/.bash_history && history -c
history -w

#shutdown
init 0
