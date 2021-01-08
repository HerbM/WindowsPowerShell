https://github.com/jrussellfreelance/powershell-scripts
https://github.com/BornToBeRoot/PowerShell
https://www.reddit.com/r/PowerShell/comments/7ni1z2/share_all_the_scripts/
https://blog.kloud.com.au/2019/07/30/darrens-powershell-snippets-volume-2/
https://blog.kloud.com.au/tag/powershell/page/3/
Using AutoRest for PowerShell to generate PowerShell Modules
12TH OF APRIL, 2019 / DARREN ROBINSON / NO COMMENTS
Recently the Beta of the AutoRest for PowerShell Generator has been made available. At the recent Microsoft MVP Summit in Seattle Garrett Serack gave those that were interested a 1 hr corridor session on getting started with AutoRest for PowerShell.
https://blog.kloud.com.au/2019/03/08/darrens-powershell-snippets-volume-1/
Join-Object Rambling Cookie Monster

https://poshoholic.com/
gci -r -force | measure -sum PSIsContainer,Length | select Property,Count,Sum  Kirk Munro

https://old.ironmansoftware.com/50-of-the-top-powershell-modules-to-check-out

Computer Configuration\Windows Settings\Security Settings\Local Policies\User Rights Assignment\Deny log on locally
secedit /configure /db %temp%\temp.sdb /cfg yourcreated.inf
http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/secedit_cmds.mspx?mfr=true

#Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name DisableWindowsUpdateAccess -Value 1
Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name DisableWindowsUpdateAccess 
-Value 1

HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon

Configuration\Windows Settings\Security Settings\Local Policies\User Rights Assignment
You can set registry-based GPO settings using the PowerShell cmdlet Set-GPPrefRegistryValue but the "Deny Log On Locally" GPO option doesn't appear to have a corresponding registry value to set.

(HKLM:\ being the standard alias for the 

PowerShell Utility https://github.com/guitarrapc/PowerShellUtil
https://powershell.org/2018/02/04/2018-community-lightning-demos/  Links to 2017 demos
http://mshforfun.blogspot.com/2006/05/perfect-prompt-for-windows-powershell.html
https://adsecurity.org/?p=94 Active Directory
https://www.microsoft.com/en-us/download/details.aspx?id=42554 4.0 but good stuff
https://github.com/groupe-sii/cheat-sheets VMWare PowerCLI 6.5
Get-Content .\vpnconfig.txt -Raw | Select-String '(?sm)<ca>(.+)</ca>' | Select -Expand Matches | Select -First 1 -Expand Value
https://github.com/HerbM/WindowsPowerShell
git init .
git remote add -t \* -f origin https://github.com/HerbM/WindowsPowerShell # <repository-url>
git checkout master

Anyone know a good module etc. to split a file or array in slices based on markers (e.g., seeing a blank line, specific text, etc)?   I keep solving this ad hoc over and over and really want to find or build a more generic solution.  (Similar to Awk and perhaps Sed patterns perhaps).
Example:  The following will split Ipconfig outout into 1 element per NIC:
((ipconfig /all) -join "`n") -split '(?sm)(?<!:)(\s*\n){2,}'| ? { $_ -match '[^\s\n]'} | % {$_; '=' * 60}     # asterik line is to allow seeing the sliced elements easily.

It actually is more complicated since it ignores the blank line between the "Adapter name:", which end in colon (:), and the adapter details.
It needed a look behind to be easy (?<!:) asserting the line before marker (e.g., adapter name) doesn't end in a colon.
Similar examples can be found in NetSh and NSLookup output.

(ipconfig) -split '\n'  | Select-String '(?sm)(.+)(\n\s*\n)'
((ipconfig /all) -join "`n") -split '(?sm)(?<!:|Windows IP Configuration)(\s*\n){2,}'| ? { $_ -match '[^\s\n]'} | % {$_; '=' * 60} 
((nslookup -type=mx www.google.com 8.8.8.8) -join "`n") -split '(?sm)(?<!:|Windows IP Configuration)(\s*\n){2,}'| ? { $_ -match '[^\s\n]'} | % {$_; '=' * 60} 

get-process powershell | select *window*,starttime
