# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "kalilinux/rolling"
#   config.ssh.username = "kali"
#   config.ssh.password = "kali"


  # config.vm.box_check_update = false

  # Bridged networks make the machine appear as another physical device on the network.
  config.vm.network "public_network"

  #config.vm.provision "file", source: "./setup.sh", destination: "/home/vagrant/setup.sh"

  config.vm.provider "vmware-desktop" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vb.memory = "4068"
  end
  config.vm.provision "shell", inline: "/bin/sh /vagrant/setup_tools.sh", args: ["kali", "vagrant"]
end