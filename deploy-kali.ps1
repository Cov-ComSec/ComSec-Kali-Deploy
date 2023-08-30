function Print-Help {
    Write-Host "Run command as follows: $PSCommandPath <virtualbox|vmware>`n"
}

if ($args.Length -ne 1) {
    Write-Host "Missing param"
    Print-Help
    exit 1
}

if ($args[0] -eq "virtualbox") {
    (Get-Content ./Vagrantfile) -replace 'config\.vm\.provider "vmware_desktop" do \|vb\|', 'config.vm.provider "virtualbox" do |vb|' | Set-Content ./Vagrantfile
}
elseif ($args[0] -eq "vmware") {
    (Get-Content ./Vagrantfile) -replace 'config\.vm\.provider "virtualbox" do \|vb\|', 'config.vm.provider "vmware_desktop" do |vb|' | Set-Content ./Vagrantfile
}
else {
    Write-Host "Argument must be 'vmware' or 'virtualbox' not '$($args[0])'"
    exit 1
}

Start-Process vagrant -ArgumentList "box", "update"
Start-Process vagrant -ArgumentList "up"

