handle_error()
{
  echo -e "An error occured during setup: $1"
  exit 1
}


# setup the kali user
create_user()
{
  # by default, Vagrant kali images do not contain a 'kali' user, so we should set that up
  echo -e "\n---> [+] Setting up user '$install_user' \n" 
    useradd -d "/home/$install_user" -u 1337 -p $install_user -m -U -s /bin/bash -G sudo "$install_user"
    echo -e "$install_user:$install_user" | chpasswd
}

reconfigure_nsswitch()
{
  # bypass university weirdness blocking access to the internet
  cd "$USER_HOME" || handle_error "\n---> [+] Failed to change directory to '$USER_HOME' \n" 
  sudo sed "s/hosts:/#hosts/g" /etc/nsswitch.conf
  echo -e "hosts:          files dns mdns4_minimal [NOTFOUND=return]" >> /etc/nsswitch.conf
  # manually restart the service otherwise the settings won't take effect
  /etc/init.d/networking force-reload
  echo -e "nameserver 8.8.8.8" >> /etc/resolv.conf
}

update_upgrade_kali()
{
  echo -e "\n---> [+] Updating and Upgrading System"
  apt update
  apt upgrade -qy
}

install_utils()
{
  echo -e "\n---> [+] Installing Docker and docker-compose"
  # docker and docker compose
  apt install -qy docker.io docker-compose
  usermod -aG docker "$install_user" 
}

install_zsh_plugins()
{
  # kali already has zsh, so just need to add any plugins
  # would be cool to add some others, will need to ask for suggestions as don't wanna clog everything up
  echo -e "\n---> [+] Installing Oh-My-ZSH and essential plugins \n"
  sudo -u "$install_user" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$USER_HOME/plugins/zsh-syntax-highlighting"
  sudo -u "$install_user" git clone https://github.com/zsh-users/zsh-completions "$USER_HOME/plugins/zsh-completions"
  sudo -u "$install_user" git clone https://github.com/zsh-users/zsh-autosuggestions "$USER_HOME/plugins/zsh-autosuggestions"
}

install_debuggers()
{
  # so people don't argue/complain over which is best
  echo -e "\n---> [+] Installing gdb PwnDbg, GEF, PEDA \n"
  apt install gdb -qy
  sudo -u "$install_user" git clone https://github.com/apogiatzis/gdb-peda-pwndbg-gef.git
  cd "$USER_HOME/gdb-peda-pwndbg-gef" || handle_error "\n---> [+] Failed to change directory to $USER_HOME/gdb-peda-pwndbg-gef \n"
  sudo -u kali ./install.sh

  echo -e "\n---> [+] Installing Rizin-Cutter \n"
  wget https://github.com/rizinorg/cutter/releases/download/v2.0.2/Cutter-v2.0.2-x64.Linux.appimage -o /usr/share/cutter.appimage
  chmod 777 /usr/share/cutter.appimage
  ln -s /usr/share/cutter.appimage /bin/cutter
}


install_web_tools()
{
  # can add tool suggestions here
  echo -e "\n---> [+] Installing some common web tools \n"
  apt install -qy wpscan dnsrecon sqlmap ffuf burpsuite masscan nikto nmap ncat gobuster enum4linux masscan exploitdb
}

install_python_tools()
{
  # Could add more python packages here too tbh
  echo -e "\n---> [+] Installing pwntools \n"
  pip3 install pwntools
}

download_wordlists()
{
  # rock you and seclists
  echo -e "\n---> [+] Downloading rockyou.txt.gz \n"
  cd "$USER_HOME" || handle_error "\n---> [+] Failed to change directory to '$USER_HOME' \n"
  mkdir /opt/wordlists
  wget -O /opt/wordlists/rockyou.txt.gz https://gitlab.com/kalilinux/packages/wordlists/-/raw/kali/master/rockyou.txt.gz?inline=false
  chmod 666 /opt/wordlists/rockyou.txt.gz
  #gunzip /opt/wordlists/rockyou.txt.gz # this will inflate the VM a lot. Might as well leave it compressed
  echo -e "\n---> [+] Downloading SecLists \n"
  sudo -u kali git clone https://github.com/danielmiessler/SecLists
}

install_kali_metapackages()
{
  # super heavy. Perhaps not add this one by default??
   echo -e "\n---> [+] Installing Kali Metapackages \n"
   apt install -yq kali-linux-core kali-tools-web # kali-tools-exploitation
}

install_priv_esc_tools()
{
  cd "$USER_HOME" || handle_error "\n---> [+] Failed to change directory to '$USER_HOME \n"
  echo -e "\n---> [+] Downloading LinPeas \n"
  sudo -u kali git clone https://github.com/carlospolop/PEASS-ng.git
  sudo -u kali wget https://raw.githubusercontent.com/diego-treitos/linux-smart-enumeration/master/lse.sh
}

install_pentesting_tools()
{
  echo -e "\n---> [+] Downloading & Setting up Autorecon \n"
  # autorecon + requirements
  cd "$USER_HOME" || handle_error "\n---> [+] Failed to change directory to '$USER_HOME \n"
  apt install -y seclists curl enum4linux feroxbuster gobuster impacket-scripts nbtscan nikto nmap onesixtyone oscanner redis-tools smbclient smbmap snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf
  sudo -u kali git clone https://github.com/Tib3rius/AutoRecon.git

  sudo -u kali python3 -m pip install -r ./AutoRecon/requirements.txt
  ln -s "$USER_HOME"/autorecon/autorecon.py /bin/autorecon
}

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
dpkg-reconfigure keyboard-configuration

# check we are superuser
if [ "$(id -u)" -ne 0 ]; then
  echo -e "\n---> [+] Please run with sudo. Exiting... \n"
  exit 0
fi

if [ $# -ne 1 ] &&  [ $# -ne 2 ]
then
  echo -e "Incorrect number of arguments supplied"
  echo -e "Usage: ./setup_tools.sh <default_user> [vagrant]"
  exit 1
fi

install_user="$1"

if [ "$2" = "vagrant" ]
  then
      is_vagrant=1
  else
      is_vagrant=0
fi

# check the supplied user exists
if id "$1" &>/dev/null; then
    echo -e "\n---> [-] User '$install_user' Found. Skipping User Creation \n"
else
    echo -e "\n---> [-] User '$install_user' not Found. Will Create User \n"
    create_user "$install_user"
fi

USER_HOME=$(getent passwd "$install_user" | cut -d: -f6)

if [ "$is_vagrant" -eq 1 ]
then
  echo -e "\n---> [+] Running in Vagrant. Will reconfigure nsswitch\n"
  reconfigure_nsswitch
fi

update_upgrade_kali
# install_zsh_plugins
install_utils
install_web_tools
install_pentesting_tools
install_python_tools
install_debuggers
download_wordlists
install_priv_esc_tools

 # I'm sure we have tons of junk now so hopefully this will clean some of it out
apt autoremove -y && apt autoclean -y

echo "Installation complete"
reboot