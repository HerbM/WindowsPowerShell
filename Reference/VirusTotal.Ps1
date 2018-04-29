<#
.\XpdfReader-win64-4.00.01.exe

choco install -y xmlstarlet.portable sift google-shortcuts-firefox monitordetails armory grepwin jq baregrep  wingrep dngrep ripgrep ethanbrown.gitaliases batch-regex gron strawberryperl wixtoolset psake 
--allow-empty-checksums


    IPMI  - Intelligent Platform Management Interface ( General Standard )
    IDRAC - Integrated Dell Remote Access ( Dell )
    ILO   - Integrated Lights-Out ( HP )
    IMM   - Integrated Management Module ( IBM )

      
gmo psutil -list
gcm -module psutil
find-module UniversalDashBoard -AllowPrerelease -MinimumVersion 1.6.0-beta4 | install-module -force -confirm:$False
gcm -module UniversalDashboard
import-module C:\Users\A469526\Documents\WindowsPowerShell\Set-LocationFile.ps1

get-wmiobject win32_process | select-object ProcessId,Name,@{Name='Username';Expression={$_.getOwner().user}},Path
get-wmiobject win32_process | select-object ProcessId,Name,{$_.getOwner().user},Path
Measure-Command { $ProcessOwners = get-wmiobject win32_process | select-object ProcessId,Name,{$_.getOwner().user},Path }
# 199 processes 17 seconds
#>

<#
 # https://github.com/darkoperator/Posh-VirusTotal 
 # https://www.virustotal.com/#/settings/apikey
 # https://developers.virustotal.com/v2.0/reference#file-report
 cd "C:\Program Files\ManagedPC\UCMS\Core\UCMS.exe"
 get-process | Where-Object { $_.path -match 'ManagedPC' } 
 (gcim Win32_Service).pathname -match 'managedpc'
  get-module *virus* -list
  find-module *virus* 
  Get-PoshVTVersion
  Get-Commannd * -Module Posh-VirusTotal
  ConvertTo-SecureString (gcb) -AsPlainText -force
  $VTMaster = Read-Host -AsSecureString
  $vtmp = Convertto-SecureString (gcb) -aspl -for 
  Set-VTAPIKey -Master $Master -api (Read-Host -AsSecureString -Prompt 'Enter VTAPIKey')
  gcm * -mod Posh-VirusTotal
#>

get-poshvtversion
# get-filehash
$ScanHashes = (dir *.exe | ForEach-Object { (get-filehash -Algorithm SHA256 $_.FullName).hash  })
Get-VTFileReport $ScanHashes[0..3] | ft Totals,Positives,ScanDate
Get-VTFileReport $ScanHashes[4..7] | ft Total,Positives,Scan_Date,SHA256
Get-VTAPIKeyInfo
#  consumed_today           : 17
#  request_rate             : 4
#  capped                   : False
#  consumption_detail_today : @{/vtapi/v2/file/report=}
#  disabled_until           :
#  type                     : public
#  monthly_allowance        : 178560
#  daily_allowance          : 5760
