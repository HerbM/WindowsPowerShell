# Getting Help
Get-Help CommandName -full# PowerShell
cmd /c Help CommandName  
CommandName /?  # many/most Windows/DOS utilities (not all) 
  Some (few) commands like OLD ping, just type name for help
command -h        #  Linux (or derivatives on Windows)  
command --help    #  Linux (or derivatives on Windows)  

 
 
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
