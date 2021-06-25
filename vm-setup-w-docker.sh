# SETUP & RUN
# curl -sL https://raw.githubusercontent.com/timherrm/proxmox/master/vm-setup-w-docker.sh | sudo -E bash -

if [ `id -u` -ne 0 ]; then
	echo Need sudo
	exit 1
fi

#apt 
apt update
do-release-upgrade
apt dist-upgrade -y
apt install vim unattended-upgrades qemu-guest-agent fail2ban nfs-common -y

#docker
apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io -y
usermod -aG docker timherrm

#mount nfs share
mkdir /dockerdata
echo "10.0.40.186:/mnt/virtio1/$HOSTNAME /dockerdata nfs defaults 0 0" >> /etc/fstab
mount /dockerdata

#resize LV
lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv

#portainer
docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /dockerdata/portainer/data:/data portainer/portainer-ce

#apt cleanup
apt autoremove -y
apt autoclean -y

#config unattended-upgrades
sed -i 's/0/1/g' /etc/apt/apt.conf.d/10periodic
sed -i 's/^\/\/.*-updates.*$/        "${distro_id}:${distro_codename}-updates";/g' /etc/apt/apt.conf.d/50unattended-upgrades

#config vim
echo "colorscheme murphy" > /etc/vim/vim.local

#config ssh
echo $'PermitRootLogin no\nMaxAuthTries 1\nProtocol 2\nPrintLastLog yes\nAllowUsers timherrm\nPasswordAuthentication no' > /etc/ssh/sshd_config.d/my.conf

#config fail2ban
echo $'[sshd]\nenabled = true\nmode = aggressive\nbantime = 10y\nfindtime = 1d\nmaxretry = 1' > /etc/fail2ban/jail.d/my.conf

#set timezone
timedatectl set-timezone Europe/Berlin

echo 'if [ "`id -u`" -eq 0 ]; then
    PS1="\[\e[0;38;5;197m\]\u\[\e[0;2;38;5;250m\]@\[\e[0;38;5;74m\]\h \[\e[0;38;5;157m\][\[\e[0;38;5;157m\]\W\[\e[0;38;5;157m\]] \[\e[0;2;38;5;250m\]\$ \[\e[0m\]"
else
    PS1="\[\e[0;38;5;209m\]\u\[\e[0;2;38;5;250m\]@\[\e[0;38;5;74m\]\h \[\e[0;38;5;157m\][\[\e[0;38;5;157m\]\W\[\e[0;38;5;157m\]] \[\e[0;2;38;5;250m\]\$ \[\e[0m\]"
fi' | tee -a /home/timherrm/.bashrc | tee -a /root/.bashrc >/dev/null

echo '"\e[A": history-search-backward
"\e[B": history-search-forward' | tee -a /home/timherrm/.inputrc | tee -a /root/.inputrc >/dev/null


#reboot

