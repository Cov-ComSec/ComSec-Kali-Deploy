# setup the kali user
create_user()
{
  printf "\n\033[0;44m---> [+] Setting up user %s \033[0m\n" % "$1"
  #  useradd -d /home/kali -u 1337 -p kali -m -U -s /bin/bash -G sudo docker kali
}

reconfigure_nsswitch()
{
  # bypass university weirdness blocking access to the internet
  cd "$USER_HOME" || printf "\n\033[0;44m---> [+] Failed to change directory to %s \033[0m\n" % "$USER_HOME"
  sudo sed "s/hosts:/#hosts/g" /etc/nsswitch.conf
  echo "hosts:          files dns mdns4_minimal [NOTFOUND=return]" >> /etc/nsswitch.conf
  echo "nameserver 8.8.8.8" >> /etc/resolv.conf
  # manually restart the service otherwise the settings won't take effect
  /etc/init.d/networking force-reload
}

update_upgrade_kali()
{
  printf "\n\033[0;44m---> [+] Updating and Upgrading System \033[0m\n"
  apt update
  apt upgrade -qy
}

install_utils()
{
  printf "\n\033[0;44m---> [+] Installing Docker and docker-compose \033[0m\n"
  # docker and docker compose
  apt install -qy docker.io docker-compose
}

install_zsh_plugins()
{
  # kali already has zsh, so just need to add any plugins
  # would be cool to add some others, will need to ask for suggestions as don't wanna clog everything up
  printf "\n\033[0;44m---> [+] Installing Oh-My-ZSH and essential plugins \033[0m\n"
  sudo -u "$install_user" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$USER_HOME/plugins/zsh-syntax-highlighting"
  sudo -u "$install_user" git clone https://github.com/zsh-users/zsh-completions "$USER_HOME/plugins/zsh-completions"
  sudo -u "$install_user" git clone https://github.com/zsh-users/zsh-autosuggestions "$USER_HOME/plugins/zsh-autosuggestions"
}

install_debuggers()
{
  # so people don't argue/complain
  printf "\n\033[0;44m---> [+] Installing gdb PwnDbg, GEF, PED\033[0m\n"
  apt install gdb -qy
  sudo -u "$install_user" git clone https://github.com/apogiatzis/gdb-peda-pwndbg-gef.git
  cd "$USER_HOME/gdb-peda-pwndbg-gef" || printf "\n\033[0;44m---> [+] Failed to change directory to %s/gdb-peda-pwndbg-gef \033[0m\n" % "$USER_HOME"
  ./install.sh

  printf "\n\033[0;44m---> [+] Installing Rizin-Cutter \033[0m\n"
  wget https://github.com/rizinorg/cutter/releases/download/v2.0.2/Cutter-v2.0.2-x64.Linux.appimage -o /usr/share/cutter.appimage
  chmod 777 /usr/share/cutter.appimage
  ln -s /usr/share/cutter.appimage /bin/cutter
}


install_web_tools()
{
  # can add tool suggestions here
  printf "\n\033[0;44m---> [+] Installing some common web tools \033[0m\n"
  apt install -qy wpscan dnsrecon sqlmap ffuf burpsuite masscan nikto nmap ncat
}

install_python_tools()
{
  # Could add more python packages here too tbh
  printf "\n\033[0;44m---> [+] Installing pwntools \033[0m\n"
  pip3 install pwntools
}

download_wordlists()
{
  # rock you and seclists
  printf "\n\033[0;44m---> [+] Downloading rockyou.txt.gz \033[0m\n"
  cd "$USER_HOME" || printf "\n\033[0;44m---> [+] Failed to change directory to %s \033[0m\n" % "$USER_HOME"
  mkdir /opt/wordlists
  wget -O /opt/wordlists/rockyou.txt.gz https://gitlab.com/kalilinux/packages/wordlists/-/raw/kali/master/rockyou.txt.gz?inline=false
  chmod 666 /opt/wordlists/rockyou.txt.gz
  #gunzip /opt/wordlists/rockyou.txt.gz # this will inflate the VM a lot. Might as well leave it compressed
  printf "\n\033[0;44m---> [+] Downloading SecLists \033[0m\n"
  sudo -u kali git clone https://github.com/danielmiessler/SecLists
}

install_kali_metapackages()
{
  # super heavy. Perhaps not add this one by default??
   printf "\n\033[0;44m---> [+] Installing Kali Metapackages \033[0m\n"
   apt install -yq kali-linux-core kali-tools-crypto-stego kali-tools-web kali-tools-exploitation
}

install_priv_esc_tools()
{
  cd "$USER_HOME" || printf "\n\033[0;44m---> [+] Failed to change directory to %s \033[0m\n" % "$USER_HOME"
  printf "\n\033[0;44m---> [+] Downloading LinPeas \033[0m\n"
  sudo -u kali git clone https://github.com/carlospolop/PEASS-ng.git
  sudo -u kali wget https://raw.githubusercontent.com/diego-treitos/linux-smart-enumeration/master/lse.sh
}

install_pentesting_tools()
{
  printf "\n\033[0;44m---> [+] Downloading & Setting up Autorecon \033[0m\n"
  # autorecon + requirements
  cd "$USER_HOME" || printf "\n\033[0;44m---> [+] Failed to change directory to %s \033[0m\n" % "$USER_HOME"
  apt install -y seclists curl enum4linux feroxbuster gobuster impacket-scripts nbtscan nikto nmap onesixtyone oscanner redis-tools smbclient smbmap snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf
  sudo -u kali git clone https://github.com/Tib3rius/AutoRecon.git

  sudo -u kali python3 -m pip install -r ./AutoRecon/requirements.txt
  ln -s "$USER_HOME"/autorecon/autorecon.py /bin/autorecon
}

  export DEBIAN_FRONTEND=noninteractive
  export DEBCONF_NONINTERACTIVE_SEEN=true
  dpkg-reconfigure keyboard-configuration
if [ $# -ne 2 ]
then
  echo "Incorrect number of arguments supplied"
  echo "Usage: ./setup_tools.sh <kali> [vagrant] "
else
  install_user="$1"
  if [ "$2" = "vagrant" ]
  then
      is_vagrant=1
  else
      is_vagrant=0
  fi
fi

# check the supplied user exists
if id "$1" &>/dev/null; then
    printf "\n\033[0;44m---> [-] User %s Found. Skipping User Creation \033[0m\n" % "$install_user"
else
    printf "\n\033[0;44m---> [-] User %s not Found. Will Create User \033[0m\n" % "$install_user"
    create_user "$install_user"
fi

USER_HOME=$(getent passwd "$install_user" | cut -d: -f6)

if [ "$is_vagrant" -eq 1 ]
then
  printf "\n\033[0;44m---> [+] Running in Vagrant. Will reconfigure nsswitch\033[0m\n"
  reconfigure_nsswitch
fi

update_upgrade_kali
install_zsh_plugins
install_utils
install_web_tools
install_pentesting_tools
install_python_tools
install_debuggers
download_wordlists
install_priv_esc_tools

 # I'm sure we have tons of junk now so hopefully this will clean some of it out
apt autoremove -y

