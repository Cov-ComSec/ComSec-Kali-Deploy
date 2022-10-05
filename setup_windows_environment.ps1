$quiet = $args[0]

# Self-elevate the script if required
 if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {

  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + " " + $VAG_PATH
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine -Wait
  if ( $LastExitCode -ne 0 ) { exit }
  Write-Output "Looks like all software is ready. Attempting to build the VM..."

  Exit
 }
}
$ErrorActionPreference = 'Stop'

if ($quiet -eq "QUIET")
{
    $has_virtualisation = "Y"
}
else
{
    $has_virtualisation = Read-host "Confirm VMware is installed (either VMware Player or Workstation) (Y/n)"
}

if (( $has_virtualisation -ne "Y" ) -or ( $has_virtualisation -ne "y" ))
{
    Write-Host "Please install VMware Player or Workstation and then re-run this script"
    return 1
}

if (-not( Test-Path -Path 'C:\ProgramData\chocolatey\bin' -PathType Container))
{
    Write-Output "Looks like Chocolatey is not installed. Attempting to Install..."
    Invoke-Expression((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
    $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (-not(Test-Path -Path 'C:\ProgramData\chocolatey\bin' -PathType Container ))
    {
        Write-Error "Chocolatey install failed. Please install manually and re-run this script"
        return 1
    }
}
else
{
    Write-Output "Chocolatey is already installed. Skipping install steps..."
}

if (-not(Test-Path -Path 'C:\HashiCorp\Vagrant\bin' -PathType Container))
{
    if ($quiet -eq "QUIET") {
        $has_vagrant = "N"
    } else {
        $has_vagrant = Read-host "Looks like Vagrant is not installed. Install it? (Y/n)"
    }

    if (( $has_vagrant -ne "N" ) -or ( $has_vagrant -ne "n" ))
    {
        Write-Output "Insalling VMware utilities"
        choco install vagrant -y

    }
}
else
{
    Write-Output "Vagrant is already installed. Skipping install steps..."
    Write-Output "Insalling VMware utilities"
}
choco install vagrant-vmware-utility --ignore-dependencies -y
vagrant plugin install vagrant-vmware-desktop
#if (-not((Test-Path -Path 'C:\tools\cygwin\bin' -PathType Container ) -or (-not(Test-Path -Path 'C:\tools\cygwin' -PathType Container ))))
#{
#    $has_cygwin = Read-host "Looks like Cygwin is not installed. Has it been installed manually? (Y/n)"
#    if (( $has_cygwin -ne "Y" ) -or ( $has_cygwin -ne "y" ))
#    {
#        choco install cyg-get -y --params "/InstallDir:C:\tools\cygwin"
#    }
#}
#else
#{
#    Write-Output "Cygwin is already installed. Skipping install steps..."
#}

if ($quiet -eq "QUIET") {
    Write-Output "Restarting"
} else {
    Read-Host "Done installing. Press Enter to Reboot. Once rebooted, run `vagrant up` from this directory"
}
Restart-Computer -Force