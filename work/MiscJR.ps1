todo

1. adcomputers
  ad 
quser

gwmi win32_bios -computer (adcomputer -filter "name -like '*'").name | select name, serialnumber

#Just online
(adcomputer -filter "name -like '*'").name | Out-File ADComputer.txt -encoding ASCII
portcheck ADComputer.txt 135 | ? { $_ -match 'open' } | ForEach-Object {
  $ComputerName, $State = $_ -split '\s+'
  # Write-Warning "[$ComputerName]"
  If ($bios = gwmi win32_bios -computer $ComputerName -ea ignore) {
    $bios | select @{N='ComputerName';E={$ComputerName}},@{N='BiosName';E={$_.Name}},SerialNumber
  } else {
    [pscustomobject]@{
      ComputerName = $ComputerName
      Name           = '' 
      SerialNumber   = ''
    }
  }
} | tee-object -variable BIOSVersion 

$BiosVersion.Computername | % { 
  $ComputerName = $_; 
  $Sessions = quser /server:$ComputerName 
}

$BiosVersion.Computername | % { Get-WinStaSession -computername $_ } | ? UserName -match 'Hmar' | % { Start-Shadow $_.UserName $_.ComputerName }

# Check all
(adcomputer -filter "name -like '*'").name | ForEach-Object {
  If ($bios = gwmi win32_bios -computer $_ -ea ignore) {
    $bios | select @{
      N=ComputerName;E={$_}},
      Name,
      SerialNumber
  } else {
    [pscustomobject]@{
      ComputerName = $_  
      Name           = '' 
      SerialNumber   = ''
    }
  }
} | tee-object -variable AllComputer


# Getting Help
Get-Help CommandName -full# PowerShell
cmd /c Help CommandName  
CommandName /?  # many/most Windows/DOS utilities (not all) 
  Some (few) commands like OLD ping, just type name for help
command -h        #  Linux (or derivatives on Windows)  
command --help    #  Linux (or derivatives on Windows)  


#  Discover machines
On or Off
Doomain or not
Windows or NOT
VM or NOT

portcheck # on network

Get-Serial   Windows/On/Domain/WMI 
 
# ======== Install-Module ActiveDirectory RSAS-AD-PowerShell =====
get-adcomputer
gcm get-adcomputer 
import-module activedirectory
get-windowsfeature *ad*
Get-WindowsFeature | ? 'DisplayName' -match 'active'
get-module servermanager -list
import-module ServerManager
get-windowsfeature *rsat*
install-windowsfeature RSAT-AD-PowerShell
gcm get-adcomputer

# =============  Setup Git Remote =============
git remote -v
git remote rm origin
git remote add origin https://www.github.com/herbm/windowspowershell
git remote -v
git pull
git pull origin master
git branch --set-upstream-to=origin/master master # tracking branch
git pull
