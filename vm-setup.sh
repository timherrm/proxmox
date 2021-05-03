# SETUP & RUN
# curl -sL https://raw.githubusercontent.com/timherrm/proxmox/master/vm-setup.sh | sudo -E bash -

if [ `id -u` -ne 0 ]; then
	echo Need sudo
	exit 1
fi

#set new password
passwd timherrm

#apt 
apt update
apt dist-upgrade -y
apt install vim unattended-upgrades qemu-guest-agent fail2ban -y

#docker
apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io -y

#portainer
docker volume create portainer_data
docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

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

reboot
