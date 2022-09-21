export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
dpkg-reconfigure keyboard-configuration

# setup the kali user
printf "\n\033[0;44m---> [+] Setting up the Kali user \033[0m\n"
useradd -d /home/kali -u 1337 -p kali -m -U -s /bin/bash -G sudo docker kali

apt update
apt upgrade -qy

# bypass university weirdness blocking access to the internet
cd "$HOME" || printf "\n\033[0;44m---> [+] Failed to change directory to %s \033[0m\n" % "$HOME"
sudo sed "s/hosts:/#hosts/g" /etc/nsswitch.conf
echo "hosts:          files dns mdns4_minimal [NOTFOUND=return]" >> /etc/nsswitch.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# manually restart the service otherwise the settings won't take effect
/etc/init.d/networking force-reload

# docker and docker compose
apt install -qy docker.io docker-compose

# kali already has zsh, so just need to add any plugins
# would be cool to add some others, will need to ask for suggestions as don't wanna clog everything up
printf "\n\033[0;44m---> [+] Installing Oh-My-ZSH and essential plugins \033[0m\n"
sudo -u kali git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/plugins/zsh-syntax-highlighting"
sudo -u kali git clone https://github.com/zsh-users/zsh-completions "$HOME/plugins/zsh-completions"
sudo -u kali git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/plugins/zsh-autosuggestions"

# so people don't argue/complain
printf "\n\033[0;44m---> [+] Installing gdb PwnDbg, GEF, PED\033[0m\n"
apt install gdb -qy
sudo -u kali git clone https://github.com/apogiatzis/gdb-peda-pwndbg-gef.git
cd "$HOME/gdb-peda-pwndbg-gef" || printf "\n\033[0;44m---> [+] Failed to change directory to %s/gdb-peda-pwndbg-gef \033[0m\n" % "$HOME"
./install.sh
cd "$HOME" || printf "\n\033[0;44m---> [+] Failed to change directory to %s \033[0m\n" % "$HOME"

# can add tool suggestions here
printf "\n\033[0;44m---> [+] Installing some common web tools \033[0m\n"
apt install -qy wpscan dnsrecon sqlmap ffuf burpsuite masscan nikto nmap ncat

# Could add more python packages here too tbh
printf "\n\033[0;44m---> [+] Installing pwntools \033[0m\n"
pip3 install pwntools

# rock you and seclists
printf "\n\033[0;44m---> [+] Downloading rockyou.txt.gz \033[0m\n"
cd "$HOME" || printf "\n\033[0;44m---> [+] Failed to change directory to %s \033[0m\n" % "$HOME"
mkdir /opt/wordlists
wget -O /opt/wordlists/rockyou.txt.gz https://gitlab.com/kalilinux/packages/wordlists/-/raw/kali/master/rockyou.txt.gz?inline=false
chmod 666 /opt/wordlists/rockyou.txt.gz
#gunzip /opt/wordlists/rockyou.txt.gz # this will inflate the VM a lot. Might as well leave it compressed
printf "\n\033[0;44m---> [+] Downloading SecLists \033[0m\n"
sudo -u kali git clone https://github.com/danielmiessler/SecLists

printf "\n\033[0;44m---> [+] Installing Rizin-Cutter \033[0m\n"
wget https://github.com/rizinorg/cutter/releases/download/v2.0.2/Cutter-v2.0.2-x64.Linux.appimage -o /usr/share/cutter.appimage
chmod 777 /usr/share/cutter.appimage
ln -s /usr/share/cutter.appimage /bin/cutter

# super heavy. Perhaps not add this one by default??
# printf "\n\033[0;44m---> [+] Installing Kali Metapackages \033[0m\n"
# apt install -yq kali-linux-core kali-tools-crypto-stego kali-tools-web kali-tools-exploitation


cd "$HOME" || printf "\n\033[0;44m---> [+] Failed to change directory to %s \033[0m\n" % "$HOME"
printf "\n\033[0;44m---> [+] Downloading LinPeas \033[0m\n"
sudo -u kali git clone https://github.com/carlospolop/PEASS-ng.git
sudo -u kali wget https://raw.githubusercontent.com/diego-treitos/linux-smart-enumeration/master/lse.sh

printf "\n\033[0;44m---> [+] Downloading & Setting up Autorecon \033[0m\n"
# autorecon + requirements
cd "$HOME" || printf "\n\033[0;44m---> [+] Failed to change directory to %s \033[0m\n" % "$HOME"
apt install -y seclists curl enum4linux feroxbuster gobuster impacket-scripts nbtscan nikto nmap onesixtyone oscanner redis-tools smbclient smbmap snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf
sudo -u kali git clone https://github.com/Tib3rius/AutoRecon.git

sudo -u kali python3 -m pip install -r ./AutoRecon/requirements.txt
ln -s "$HOME"/autorecon/autorecon.py /bin/autorecon

# I'm sure we have tons of junk now so hopefully this will clean some of it out
apt autoremove -y
