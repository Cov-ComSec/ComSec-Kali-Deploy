export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
dpkg-reconfigure keyboard-configuration


cd /home/vagrant/ || printf "\n\033[0;44m---> [+] Failed to change directory to /home/vagrant/ \033[0m\n"; exit
sudo sed "s/hosts:/#hosts/g" /etc/nsswitch.conf
echo "hosts:          files dns mdns4_minimal [NOTFOUND=return]" >> /etc/nsswitch.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

/etc/init.d/networking force-reload

apt update
apt upgrade -y

printf "\n\033[0;44m---> [+] Installing Oh-My-ZSH and essential plugins \033[0m\n"
sudo -u vagrant git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/vagrant/plugins/zsh-syntax-highlighting
sudo -u vagrant git clone https://github.com/zsh-users/zsh-completions /home/vagrant/plugins/zsh-completions
sudo -u vagrant git clone https://github.com/zsh-users/zsh-autosuggestions /home/vagrant/plugins/zsh-autosuggestions

printf "\n\033[0;44m---> [+] Installing gdb PwnDbg, GEF, PED\033[0m\n"
apt install gdb -y
sudo -u vagrant git clone https://github.com/apogiatzis/gdb-peda-pwndbg-gef.git
cd /home/vagrant/gdb-peda-pwndbg-gef || printf "\n\033[0;44m---> [+] Failed to change directory to /home/vagrant/gdb-peda-pwndbg-gef \033[0m\n"; exit
./install.sh
cd /home/vagrant

printf "\n\033[0;44m---> [+] Installing some common web tools \033[0m\n"
apt install -y wpscan dnsrecon sqlmap ffuf burpsuite masscan nikto nmap ncat

printf "\n\033[0;44m---> [+] Installing pwntools \033[0m\n"
pip3 install pwntools

cd /home/vagrant || printf "\n\033[0;44m---> [+] Failed to change directory to /home/vagrant \033[0m\n"; exit
printf "\n\033[0;44m---> [+] Downloading rockyou.txt.gz \033[0m\n"
mkdir /opt/wordlists
wget -O /opt/wordlists/rockyou.txt.gz https://gitlab.com/kalilinux/packages/wordlists/-/raw/kali/master/rockyou.txt.gz?inline=false
chmod 666 /opt/wordlists/rockyou.txt.gz
#gunzip /opt/wordlists/rockyou.txt.gz # this will inflate the VM a lot. Might as well leave it compressed
printf "\n\033[0;44m---> [+] Downloading SecLists \033[0m\n"
sudo -u vagrant git clone https://github.com/danielmiessler/SecLists

printf "\n\033[0;44m---> [+] Installing Rizin-Cutter \033[0m\n"
wget https://github.com/rizinorg/cutter/releases/download/v2.0.2/Cutter-v2.0.2-x64.Linux.appimage -o /usr/share/cutter.appimage
chmod 777 /usr/share/cutter.appimage
ln -s /usr/share/cutter.appimage /bin/cutter

# printf "\n\033[0;44m---> [+] Installing Kali Metapackages \033[0m\n"
# apt install -yq kali-linux-core kali-tools-crypto-stego kali-tools-web kali-tools-exploitation

cd /home/vagrant || printf "\n\033[0;44m---> [+] Failed to change directory to /home/vagrant \033[0m\n"; exit
printf "\n\033[0;44m---> [+] Downloading LinPeas \033[0m\n"
sudo -u vagrant git clone https://github.com/carlospolop/PEASS-ng.git
sudo -u vagrant wget https://raw.githubusercontent.com/diego-treitos/linux-smart-enumeration/master/lse.sh

printf "\n\033[0;44m---> [+] Downloading & Setting up Autorecon \033[0m\n"
# autorecon + requirements
cd /home/vagrant
apt install -y seclists curl enum4linux feroxbuster gobuster impacket-scripts nbtscan nikto nmap onesixtyone oscanner redis-tools smbclient smbmap snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf
sudo -u vagrant git clone https://github.com/Tib3rius/AutoRecon.git

sudo -u vagrant python3 -m pip install -r ./AutoRecon/requirements.txt
ln -s /home/vagrant/autorecon/autorecon.py /bin/autorecon

apt autoremove -y