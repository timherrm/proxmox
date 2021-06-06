# SETUP & RUN
# curl -sL https://raw.githubusercontent.com/timherrm/proxmox/master/vm-setup.sh | sudo -E bash -

if [ `id -u` -ne 0 ]; then
	echo Need sudo
	exit 1
fi

#apt 
apt update
do-release-upgrade
apt dist-upgrade -y
apt install vim unattended-upgrades qemu-guest-agent fail2ban -y

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


reboot
