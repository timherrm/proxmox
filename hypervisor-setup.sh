lvresize -l +100%FREE /dev/pve/root
xfs_growfs /dev/mapper/pve-root

rm /etc/apt/sources.list.d/pve-enterprise.list
echo $'deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription' > /etc/apt/sources.list.d/pve-no-subscription.list

apt update
apt install vim -y
apt dist-upgrade -y
apt autoremove -y
apt autoclean -y

timedatectl set-timezone Europe/Berlin

echo 'if [ "`id -u`" -eq 0 ]; then
    PS1="\[\e[0;38;5;197m\]\u\[\e[0;2;38;5;250m\]@\[\e[0;38;5;74m\]\h \[\e[0;38;5;157m\][\[\e[0;38;5;157m\]\W\[\e[0;38;5;157m\]] \[\e[0;2;38;5;250m\]\$ \[\e[0m\]"
else
    PS1="\[\e[0;38;5;209m\]\u\[\e[0;2;38;5;250m\]@\[\e[0;38;5;74m\]\h \[\e[0;38;5;157m\][\[\e[0;38;5;157m\]\W\[\e[0;38;5;157m\]] \[\e[0;2;38;5;250m\]\$ \[\e[0m\]"
fi' | tee -a /root/.bashrc >/dev/null

echo '"\e[A": history-search-backward
"\e[B": history-search-forward' | tee -a /root/.inputrc >/dev/null
