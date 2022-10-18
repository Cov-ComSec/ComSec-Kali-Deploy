# ComSec-Kali-Deploy

Still very much a **draft** provisioning script for the ComSec kali instance for the labs.

## How to use this Repository

1. Clone this repo
2. Ensure VMWare Workstation or Player is installed
3. Either:
   - Configure system manually
   - Use the `setup_windows_environment.ps1` script to configure the system for you (using Vagrant).
     - Installs choco, Vagrant (vagrant vmware plugin, vagrant vmware utility), 
     - Requires administrator privileges.

### Manual Setup

- Download the latest Kali from [here](https://www.kali.org/get-kali/)
- Create a new Kali VM in VMWare Workstation or Player
- Copy the script `setup_tools.sh` to the Kali VM
- Run the script `setup_tools.sh` in the Kali VM. First argument is the username of the primary user. Will be created if not exist
  - Recommended syntax: `sudo ./setup_tools.sh kali`
- Log in. If user was created, credentials are `user:user` 

### Automated Setup

- Run `setup_windows_environment.ps1`. Supply answers to the prompts
- When prompted, reboot PC
- Once rebooted, navigate to the `ComSec-Kali-Deploy` directory and run `vagrant plugin install vagrant-vmware-desktop` then `vagrant up`. Provisioning will begin.
- Once finished, login with `kali:kali`

## TODO

- [ ] Add FireFox privacy settings
- [ ] Add a mode for user-free provisioning
- [ ] Automate installing vagrant vmware plugin
- [ ] More features...
