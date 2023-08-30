#!/usr/bin/env bash

print_help() {
  echo -e "Run command as folows:\t$0 <virtualbox|vmware>\n"
}

if [ $# -ne 1 ] 
then
  echo -ne "Missing param"
  print_help
fi


if [ "$1" = "virtualbox" ]; 
then
  sed -i 's/config\.vm\.provider "vmware-desktop" do |vb|/config\.vm\.provider "virtualbox" do |vb|/' ./Vagrantfile
elif [ "$1" = "vmware" ];
then
  sed -i 's/config\.vm\.provider "virtualbox" do |vb|/config\.vm\.provider "vmware_desktop" do |vb|/' ./Vagrantfile 
else
  echo "Argument must be 'vmware' or 'virtualbox' not '$1'"
  print_help
  exit 1
fi


vagrant box update
vagrant up
