 # Self-elevate the script if required
 if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine -Wait
  if ( $LastExitCode -ne 0 ) { exit }
  Write-Output "Looks like all software is ready. Attempting to build the VM..."

  $CommandLine = "-File `"" + $PWD + "start_container.ps1" + "`" "
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine -Wait
  Read-host "Done"
  Exit
 }
}
$ErrorActionPreference = 'Stop'
$has_virtualisation = Read-host "Confirm VMware is installed (either VMware Player or Workstation) (Y/n)"

if (( $has_virtualisation -ne "Y" ) -or ( $has_virtualisation -ne "y" ))
{
    Write-Host "Please install VMware Player or Workstation and then re-run this script"
    return 1
}

if (-not( Test-Path -Path 'C:\ProgramData\chocolatey\bin' -PathType Container))
{
    Write-Output "Looks like Chocolatey is not installed. Attempting to Install..."
    $CommandLine = "-File `"" + $PWD + "install_choco.ps1" + "`" "
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine -Wait
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
    $has_vagrant = Read-host "Looks like Vagrant is not installed. Has it been installed manually (Y/n)"
    if (( $has_vagrant -ne "Y" ) -or ( $has_vagrant -ne "y" ))
    {
        Write-Output "Insalling VMware utilities"
        choco install vagrant -y
        choco install vagrant-vmware-utility --ignore-dependencies -y
        vagrant plugin install vagrant-vmware-desktop
    }
}
else
{
    Write-Output "Vagrant is already installed. Skipping install steps..."
    Write-Output "Insalling VMware utilities"
    choco install vagrant-vmware-utility --ignore-dependencies -y
    vagrant plugin install vagrant-vmware-desktop
}

if (-not((Test-Path -Path 'C:\tools\cygwin\bin' -PathType Container ) -or (-not(Test-Path -Path 'C:\tools\cygwin' -PathType Container ))))
{
    $has_cygwin = Read-host "Looks like Cygwin is not installed. Has it been installed manually? (Y/n)"
    if (( $has_cygwin -ne "Y" ) -or ( $has_cygwin -ne "y" ))
    {
        choco install cyg-get -y --params "/InstallDir:C:\tools\cygwin"
    }
}
else
{
    Write-Output "Cygwin is already installed. Skipping install steps..."
}

return 0