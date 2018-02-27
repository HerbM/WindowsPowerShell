[CmdLetBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param (
  [Alias('DotNet')]                                    [switch]$ShowDotNetVersions,
  [Alias('Modules')]                                   [switch]$ShowModules,
  [Alias('IModules')]                                  [switch]$InstallModules,
                                                       [switch]$ForceModuleInstall,
  [Alias('ClobberAllowed')]                            [switch]$AllowClobber,
  [Alias('SilentlyContinue')]                          [switch]$Quiet,
  [Alias('PSReadlineProfile','ReadlineProfile','psrl')][switch]$PSReadline,
  [ValidateSet('AllUsers','CurrentUser')]              [string]$ScopeModule='AllUsers',
  [Parameter(ValueFromRemainingArguments=$true)]     [String[]]$RemArgs
)

# Close with Set-ProgramAlias
# Add new set-programalias nscp 'C:\Program Files\NSClient++\nscp.exe' -force -scope

# Fix RDP alias, Put 7-zip, Util,Unx in S:\Programs, New program searcher?  Better?
# Boottime,ProfilePath moved up,LINE/FILE/Write-LOG,LogFilePath?,7z
# Add/fix BootTime function
# Move $ProfileDirectory up
# Move utility extract up (LINE, FILE, WRITE-LOG)
# working on LogFilePath
# worked on 7z  -- 
# TODO: need Notepad++, 7zip, Git, ??? to be on path with shortcuts
# TODO: LogFile not being written
# https://null-byte.wonderhowto.com/how-to/use-google-hack-googledorks-0163566/

#$MyInvocation
#$MyInvocation.MyCommand
function Get-CurrentLineNumber { $MyInvocation.ScriptLineNumber }
New-Alias -Name   LINE   -Value Get-CurrentLineNumber -Description 'Returns the current (caller''s) line number in a script.' -force -Option allscope
write-warning "$(LINE) PowerShell $($psversiontable.PSVersion.tostring())" 
$ProfileDirectory = Split-Path $Profile
write-information "Use `$Profile for path to Profile: $Profile"
# Chrome key mapper?  chrome://extensions/configureCommands
# Chrome extensions   chrome://extensions/


# "line1","line2" -join [environment]::NewLine
function Get-NewLine { [environment]::NewLine }; new-alias NL Get-NewLine -force
# "line1","line2" -join (NL)
# https://github.com/FriedrichWeinmann/PSReadline-Utilities
# https://github.com/FriedrichWeinmann/functions
# PSFramework
# Install-Module -Scope CurrentUser -Name Assert

$ProfileLogName = ($ProfileFile -replace '\.ps1$'), 'LOG.txt'
$ProfileLogPath = Join-Path $ProfileDirectory $ProfileName 
Write-Information "$(LINE) ProfileLogPath: $ProfileLogPath"
try {
  if (Test-Path (Join-Path $ProfileDirectory 'utillity.ps1')) {
    Join-Path $ProfileDirectory 'utillity.ps1'
  }
  Write-Log "(FLINE) Using Write-Log from Utility.ps1" -file $ProfileLogPath 3
} catch { # just ignore and take care of below
} finally {}

if (! (Get-Command 'Write-Log')) { 
  New-Alias Write-Log Write-Verbose 
  Write-Warning "$(LINE) Utility.ps1 not found.  Defined alias for Write-Log" 
  function Get-CurrentLineNumber { $MyInvocation.ScriptLineNumber }
  function Get-CurrentFileName   { split-path -leaf $MyInvocation.PSCommandPath   }   function Get-CurrentFileLine   {
    if ($MyInvocation.PSCommandPath) {
      "$(split-path -leaf $MyInvocation.PSCommandPath):$($MyInvocation.ScriptLineNumber)"
    } else {"GLOBAL:$(LINE)"}
  }
  function Get-CurrentFileName1  {
    if ($var = get-variable MyInvocation -scope 1 -value) {
      if ($var.PSCommandPath) { split-path -leaf $var.PSCommandPath }
      else {'GLOBAL'}
    } else {"GLOBAL"}
  }   #$MyInvocation.ScriptName
  New-Alias -Name   LINE   -Value Get-CurrentLineNumber -Description 'Returns the current (caller''s) line number in a script.' -force -Option allscope
  New-Alias -Name   FILE   -Value Get-CurrentFileName   -Description 'Returns the name of the current script file.' -force             -Option allscope
  New-Alias -Name   FLINE  -Value Get-CurrentFileLine   -Description 'Returns the name of the current script file.' -force             -Option allscope
  New-Alias -Name   FILE1  -Value Get-CurrentFileName1  -Description 'Returns the name of the current script file.' -force             -Option allscope

  function Write-Log {
    param (
      [string]$Message,
      [int]$Severity = 3, ## Default to a high severity. Otherwise, override
      [string]$File
    )
    try {
      if (!$LogLevel) { $LogLevel = 3 }
      if ($Severity -lt $LogLevel) { return }
      write-verbose $Message
      $line = [pscustomobject]@{
        'DateTime' = (Get-Date -f "yyyy-MM-dd-ddd-HH:mm:ss") #### (Get-Date)
        'Severity' = $Severity
        'Message'  = $Message
      }
      if (-not $LogFilePath) {
        $LogFilePath  =  "$($MyInvocation.ScriptName)" -replace '(\.ps1)?$', ''
        $LogFilePath += '-Log.txt'
      }
      if ($File) { $LogFilePath = $File }
      if ($psversiontable.psversion.major -lt 3) {
        $Entry = "`"$($line.DateTime)`", `"$($line.$Severity)`", `"$($line.$Message)`""
        $null = Out-file -enc utf8 -filepath $LogFilePath -input $Entry -append -erroraction Silentlycontinue -force
      } else {
        $line | Export-Csv -Path $LogFilePath -Append -NoTypeInformation -erroraction Silentlycontinue -force -enc ASCII
      }
    } catch {
      $ec   = ('{0:x}' -f $_.Exception.ErrorCode); $em = $_.Exception.Message; $in = $_.InvocationInfo.PositionMessage
      $description =  "$(FLINE) Catch $in $ec, $em"
      "Logging: $description" >> $LogFilePath
    }
  }

  function LINE {
    param ([string]$Format,[switch]$Label)
    $Line = '[1]'; $Suffix = ''
    If ($Format) { $Label = $True }
    If (!$Format) { $Format = 'Line {0,3}:' }
    try {
      if (($L = get-variable MyInvocation -scope 1 -value -ea 0) -and $L.ScriptLineNumber) {
        $Line = $L.ScriptLineNumber
      }
    } catch {
      $Suffix = '(Catch in LINE)'
    }
    if ($Label) { $Line = $Format -f $Line }
    "$Line$Suffix"
  }
}

<#
#>

write-information "Profile loaded: $($MyInvocation.MyCommand.Path)"

$PSVersionNumber = "$($psversiontable.psversion.major).$($psversiontable.psversion.minor)" -as [double]
write-information "$(LINE) PowerShell version PSVersionNumber: [$PSVersionNumber]"

$ForceModuleInstall = [boolean]$ForceModuleInstall
$AllowClobber       = [boolean]$AllowClobber
$Confirm            = [boolean]$Confirm

<#
If ($NotepadPlusPlus = @(where.exe 'notepad++*.exe'  2>$Null)) {
} elseif (($NotepadPlusPlus = 
        (Get-Alias np -ea 0).definition | ? { Test-Path $NotepadPlusPlus -ea 0 }       
  # Nothing to do but set location          
} else {
  $ProgFiles = (get-childitem ENV:prog*).value | select -uniq 
  dir $ProgFiles -incl NotePad++ -rec

}
# new-alias np 'C:\util\notepad++.exe' -force
# new-alias np 'S:\Programs\Portable\Notepad++Portable\Notepad++Portable.exe' -force -scope global
#>

# 'C:\Program Files (x86)\Notepad++\Note*.exe'   # ECS-DCTS02  Dec 2017 7.5.4
#  S:\Programs\Notepad++ # 1/2/2018 Notepad++Portable.exe
#  S:\Programs\Notepad++\app\Notepad++\   # Dec 2017
#  S:\Programs\Herb\util\notepad++Portable.exe

### $SearchNotePadPlusPlus = @('S:\Programs' )
<#
$NotepadPlusPlus = (
  @((get-childitem 'ENV:Notepad++','ENV:NotepadPlusPlus' -ea 0).value -split ';'  |
    ? { $_ -match '\S'} |
    % { $_,(Join-Path $_ 'Notepad++*'  2>$Null)} | ? {Test-Path $_ -ea 0})      +
  (where.exe notepad++ 2>$null)                                +   
  (gal np -ea 0).definition                                    +
  ((get-childitem ENV:prog* -ea 0).value | select -uniq        | 
    % {Join-Path $_ 'Notepad++*'} | ? {Test-Path $_ -ea 0})      +
  ('C:\ProgramData\chocolatey\bin',
   'S:\Programs\Notepad++*','S:\Programs\Portable\Notepad++*',  
   'T:\Programs\Notepad++*','T:\Programs\Portable\Notepad++*',
   'S:\Programs\Herb\util', 'T:\Programs\Herb\util',
   'D:\wintools\Tools\hm') | 
   Get-ChildItem -include 'notepad++*.exe' -excl '.paf.' -file -recurse -ea 0 |
   % { write-warning "$(LINE) $_"; $_} |   
   select -first 1).fullname
if ($NotepadPlusPlus) { new-alias np $NotepadPlusPlus -force -scope Global }
#>
function Set-ProgramAlias {
  param(
    [Alias('Alias')]  $Name,
    [Alias('Program')]$Command,
            [string[]]$Path,
            [string[]]$Preferred,
    [switch]          $FirstPath,  
    [switch]          $IgnoreAlias  
  )
  $Old = Get-Alias $Name -ea 0
  if ($IgnoreAlias) { remove-item Alias:$Name -force -ea 0 }
  $SearchPath = if ($FirstPath) {
    $Path + (where.exe $Command 2>$Null) + @(get-command $Name -all -ea 0).definition
  } else {  
    @(get-command $Name -all -ea 0).definition + (where.exe $Command 2>$Null) + $Path
  }
  Remove-Item Alias:$Name -force -ea 0                                  
  ForEach ($Location in $SearchPath) {
    if ($Location -and (Test-Path $Location -pathType Leaf -ea 0)) {
      new-alias $Name $Location -force -scope Global
      break
    } elseif ( $Location -and $Command -and 
              ($Location = Join-Path $Location $Command -ea 0) -and 
              (Test-Path $Location -pathType Leaf)) {
      new-alias $Name (Join-Path $Location $Command) -force -scope Global    
      break
    }
  }
  if (Get-Command $Name -commandtype alias -ea 0) { 
    write-warning "$(LINE) $Name found: $Location [$((gal $Name -ea 0).definition)]"
  } else {
    write-warning "$(LINE) $Name NOT found on path or in: $($SearchPath -join '; ')"
  }
}
Set-ProgramAlias np notepad++.exe @('C:\Util\notepad++.exe', 
   'C:\ProgramData\chocolatey\bin\notepad++.exe',
   'S:\Programs\Notepad++\app\Notepad++\notepad++.exe'
   'S:\Programs\Notepad++\notepad++portable.exe',
   'T:\Programs\Notepad++\app\Notepad++\notepad++.exe',
   'T:\Programs\Portable\Notepad++portable.exe',
   'S:\Programs\Herb\util\notepad++.exe','T:\Programs\Herb\util\notepad++.exe',
   'D:\wintools\Tools\hm\notepad++.exe')  -FirstPath  
Set-ProgramAlias nscp nscp.exe 'C:\Program Files\NSClient++\nscp.exe' -FirstPath
Set-ProgramAlias 7z 7z.exe @('C:Util\7-Zip\app\7-Zip64\7z.exe', 
                             'C:\ProgramData\chocolatey\bin\7z.exe',
                             'S:\Programs\7-Zip\app\7-Zip64\7z.exe'
                           )  -FirstPath  
   
function Select-History {
 param($Pattern, [int]$Count=9999, $Exclude='Select-History|(\bsh\b)') 
 (h).commandline -match $Pattern -notmatch $Exclude
 select -last $Count 
}
new-alias sh Select-History -force -scope Global

# 'Thu, 08 Feb 2018 07:47:42 -0800 (PST)' -replace '[^\d]+$' -as [datetime] 13:47:42 -0800 (PST)'
# 'Thu, 08 Feb 2018 07:47:42 -0800 (PST)' -replace '[^\d]+$' -as [datetime] 13:47:42 -0800 (PST)'
#$raw = 'Thu, 08 Feb 2018 13:47:42 -0800 (PST)'
#$pattern = 'ddd, dd MMM yyyy H:mm:ss zzz \(PST)'
#[DateTime]::ParseExact($raw, $pattern, $null)

# $MyInvocation
if ($MyInvocation.HistoryID -eq 1) {
  if (gcm write-information -type cmdlet,function -ea 0) {
    $InformationPreference = 'Continue'
    Remove-Item alias:write-information -ea 0
    $global:informationpreference = $warningpreference
  } else {
    write-warning '$(LINE) Use write-warning for information if write-information not available'
    new-alias write-information write-warning -force # -option allscope
  }
}

if ($Quiet -and $global:informationpreference) {
  $informationpreferenceSave = $global:informationpreference
  $global:informationpreference = 'SilentlyContinue'
  $script:informationpreference = 'SilentlyContinue'
  write-information "SHOULD NOT WRITE"
}

function Get-RunTime { 
  param(
    [Microsoft.PowerShell.Commands.HistoryInfo[]]$historyitem, 
    [switch]$Full
  ) 
  $width = +1 * "$((($HistoryItem | measure -max id).maximum))".length
  $F1 = '{0,5:N2}'; 
  $F2 = "ID# {1,$($Width):D}: "
  write-verbose "$(FLINE) width $Width $F2"
  foreach ($hi in $HistoryItem) {
    $CL = $hi.commandline
    $ID = $hi.id
    switch ($hi.endexecutiontime - $hi.startexecutiontime) {
      {$Full                } { $_                                      } 
      {$_.Days         -gt 0} {"$F1 Days  $F2 $CL" -f $_.TotalDays   ,$ID; break } 
      {$_.Hours        -gt 0} {"$F1 Hours $F2 $CL" -f $_.TotalHours  ,$ID; break }
      {$_.Minutes      -gt 0} {"$F1 Mins  $F2 $CL" -f $_.TotalMinutes,$ID; break }
      {$_.Seconds      -gt 0} {"$F1 Secs  $F2 $CL" -f $_.TotalSeconds,$ID; break }
      {$_.Milliseconds -gt 0} {"$F1 ms    $F2 $CL" -f $_.TotalSeconds,$ID; break }
    }
  }
}

<#
  $7zipPath = @(get-command 7z -all -ea 0).definition +
               (where.exe   7z.exe 2>$Null) + @('C:Util\7-Zip\app\7-Zip64\7z.exe', 
                                        'C:\ProgramData\chocolatey\bin\',
                                        'S:\Programs\7-Zip\app\7-Zip64\7z.exe'
                                       )
  Remove-Item Alias:7z -force -ea 0                                  
  ForEach ($7z in $7zipPath) {
    if ($7zipFound = Test-Path $7zipPath) {
      new-alias 7z $7z -force -scope Global
      break
    }
  }
  if (Get-Command 7z -commandtype alias -ea 0) { 
    write-warning "$(LINE) 7zip found: $7z"
  } else {
    write-warning "$(LINE) 7zip NOT found on path or in: $($7zipPath -join '; ')"
  }
}
#>
get-itemproperty 'HKCU:\CONTROL PANEL\DESKTOP' -name WindowArrangementActive | 
  Select WindowArrangementActive | FL | findstr "WindowArrangementActive"
set-itemproperty 'HKCU:\CONTROL PANEL\DESKTOP' -name WindowArrangementActive -value 0 -type dword -force

# 7-Zip        http://www.7-zip.org/download.html
# Git          https://git-scm.com/download/win
#              https://github.com/git-tips/tips
#              C:\Program Files\Git\mingw64\share\doc\git-doc\giteveryday.html
# Regex        http://www.grymoire.com/Unix/Regular.html#uh-12
#              http://www.regexlib.com/DisplayPatterns.aspx 
# AwkRef       http://www.grymoire.com/Unix/AwkRef.html
# Notepad++    https://notepad-plus-plus.org/download/v7.5.4.html
# ArsClip      http://www.joejoesoft.com/vcms/97/
# Aria2        https://github.com/aria2/aria2/releases/tag/release-1.33.1
# Deluge       http://download.deluge-torrent.org/windows/?C=M;O=D
# Transmission https://transmissionbt.com/download/
# WinMerg      http://developeronfire.com/blog/configuration-of-git-on-windows-to-make-life-easy
# NotesProfile See: NotesProfile.txt
# docker       https://docs.docker.com/install/windows/docker-ee/#use-a-script-to-install-docker-ee
#              https://github.com/wsargent/docker-cheat-sheet

function Get-CurrentIPAddress {(ipconfig) -split "`n" | ? {$_ -match 'IPv4'} | % {$_ -replace '^.*\s+'}}
function Get-WhoAmI { "[$PID]",(whoami),(hostname) + (Get-CurrentIPAddress) -join ' ' }

$CurrentWindowTitle = $Host.ui.RawUI.WindowTitle
if ($CurrentWindowTitle -match 'Windows PowerShell([\(\)\s\d]*)$') {
  $Host.ui.RawUI.WindowTitle += " $(Get-WhoAmI)"
}

If ($ShowDotNetVersions) {
  write-information ".NET dotnet versions installed"
  $DotNetKey = @('HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP',
                 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4')
  @(foreach ($key in  $DotNetKey) { gci $key }) | get-itemproperty  -ea 0 | select @{N='Name';E={$_.pspath -replace '.*\\([^\\]+)$','$1'}},version,InstallPath,@{N='Path';E={($_.pspath -replace '^[^:]*::') -replace '^HKEY[^\\]*','HKLM:'}}
}

$DefaultConsoleTitle = 'Administrator: Windows PowerShell'
# https://github.com/PowerShell/PowerShellGet/archive/1.6.0.zip
$PSGallery = Get-PSRepository PSGallery -ea 0
if ($PSGallery) { 
  $PSGallery 
  if ($PSGallery.InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -name 'PSGallery' -InstallationPolicy 'Trusted' -ea 0
    Get-PSRepository -name 'PSGallery' -ea 0
  }
}

$PSVersionNumber = "$($psversiontable.psversion.major).$($psversiontable.psversion.minor)" -as [double]
if (!(Get-Module 'Jump.Location' -listavailable -ea 0) -and $PSVersionNumber -lt 6) {  
  $parms = @('-force')
  if ($PSVersionNumber -ge 5.1) { $parms += '-AllowClobber' }
  Install-Module 'Jump.Location' ### @Parms 
}
Import-Module jump.location

function Update-ModuleList {
  [CmdLetBinding(SupportsShouldProcess = $true,ConfirmImpact='Medium')]
  param(
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [string[]]$name='pscx'
  )
  begin {}
  process {
    foreach ($ModuleName in $Name) {
      $InstalledModule = @(get-module $ModuleName -ea 0 -list | sort -desc Version)
      $version = if ($InstalledModule) {
        $InstalledModule | % {
          write-warning "$(LINE) Installed module: $($_.Version) $($_.Name)"
        }
        $InstalledModule = $InstalledModule[0]
        $InstalledModule.version
      } else {
        write-warning "Module $ModuleName not found, searching gallery..."
        '0.0'  # set ZERO VERSION
      }
      $FoundModule = find-module $ModuleName -minimum $version -ea 0 |
                     sort version -desc  | select -first 1
      if ($FoundModule) {
        write-warning "$($FoundModule.Version) $($FoundModule.Name)"
        If ($InstalledModule) {
          if ($FoundModule.version -gt $InstalledModule.version) {
            write-warning "Updating module $ModuleName to version: $($FoundModule.version)..."
            try {
              update-module $ModuleName -force -confirm:$confirm -whatif:$whatif -required $FoundModule.version
            } catch {
              install-module -force -confirm:$confirm -minimum $version -scope 'AllUsers' -whatif:$whatif
            }
          }
        } else {
          write-warning "Installing module $ModuleName ... ";
          install-module -force -confirm:$confirm -minimum $version -scope 'AllUsers' -whatif:$whatif
        }
      } else {
        write-warning "Module $ModuleName NOT FOUND on repository!"
      }
    }
  }  ## Process block
  end {}
}

$RecommendedModules = @(
  'pester',
  'carbon',
  'pscx',
  'PowerShellCookbook',
  'ImportExcel',
  'VMWare.PowerCli',
  'ThreadJob',
  'PSScriptAnalyzer',
  'PSGit',
  'Jump.Location',
  'Veeam.PowerCLI-Interactions',
  'PSReadLine',
  'PSUtil'
)

# DSC_PowerCLISnapShotCheck  PowerCLITools  PowerCLI.SessionManager PowerRestCLI
# PowerShell CodeManager https://bytecookie.wordpress.com/
# ChocolateyGet
# https://github.com/FriedrichWeinmann/PSReadline-Utilities
# https://github.com/FriedrichWeinmann/functions
# PSFramework
# Install-Module -Scope CurrentUser -Name Assert


if ($InstallModules) {
  Install-ModuleList $RecommendedModules
} else {
  # get-module -list $RecommendedModules
}

if ($ShowModules) {
 get-module -list | ? {$_.name -match 'PowerShellGet|PSReadline' -or $_.author -notmatch 'Microsoft' } |
   ft version,name,author,path
} else {
}

# Get .Net Constructor parameters
# ([type]"Net.Sockets.TCPClient").GetConstructors() | ForEach { $_.GetParameters() } | Select Name,ParameterType
function Get-Constructor {
  param([Alias('Name')][string[]]$TypeName)
  ForEach ($Name in $TypeName) {
    ([type]$Name).GetConstructors() | ForEach { write-host "$_"; $_.GetParameters() } | Select Name,ParameterType
  }
}

write-information "https://blogs.technet.microsoft.com/pstips/2014/05/26/useful-powershell-modules/"
$PSCXprofile = 'C:\Users\hmartin\Documents\WindowsPowerShell\Pscx.UserPreferences'
write-information "import-module -noclobber PSCX $PSCXprofile"
if ($psversiontable.psversion.major -lt 6) {
  write-information "import-module -noclobber PowerShellCookbook"
}

<#
[System.Windows.Forms.Screen]::AllScreens
[System.Windows.Forms.Screen]::PrimaryScreen
# Make nicely formatted simple directory for notes:
dir | sort LastWriteTime -desc | % { '{0,23} {1,11} {2}' -f $_.lastwritetime,$_.length,$_.name } 
#>

<#
ts.ecs-support.com:32793  terminal server 10.10.11.80
ts.ecs-support.com:32795 FS02
#>
$j1 = $ecsts01 = 'ts.ecs-support.com:32793'
$j2 = $ecsts02 = 'ts.ecs-support.com:32795'
$j1s = 'ecs-DCts01'
$j2x = 'ecs-DCts02'


function New-RDPSession {
  param(
    [Alias('Remote','Target','Server')]$ComputerName,
    [Alias('ConnectionFile','File','ProfileFile')]$path='c:\bat\good.rdp',
    [int]$Width=1350, [int]$Height:730,
    [Alias('NoConnectionFile','NoFile','NoPath')][switch]$NoProfileFile
  )
  $argX = $args
  $argX += '/prompt'
  if ($NoProfileFile) { mstsc /v:$ComputerName /w:$Width /h:$Height @argX }
  else                { mstsc /v:$ComputerName $Path @argX }
} New-Alias RDP New-RDPSession -force

if ($AdminEnabled -and (get-command 'ScreenSaver.ps1' -ea 0)) { ScreenSaver.ps1 }

<# Testing ideas #>

function Get-HelpLink {
  $args
  "Args: $($args.count) $($args.gettype())"
  $a = $args
  (((help @a -full) -join ' ## ') -split '(\s+##\s+){2,}' | sls '.*http.*' -all |
    select -expand matches).value -replace ' ## ',"`n" | % {"$_`n"} | fl
}; New-Alias ghl Get-HelpLink -force

function Get-HelpLink {
  $a = $args
  #$outputEncoding=[System.Console]::OutputEncoding
  (((help @a -full) -join ' ## ') -split '(\s+##\s+){2,}' | sls '.*http.*' -all |
    select -expand matches).value -replace ' ## ',"`n" | % {"$_`n"} | fl
}
; New-Alias ghl Get-HelpLink -force
# get-help about_* -full | % { '{0,-38}{1,6}  {2}' -f $_.Name,$_.Length,$_.Synopsis }

if (Test-Path "$Home\Documents\WindowsPowerShell\tt.xml") {
	if ($hc = import-clixml -first 1 "$Home\Documents\WindowsPowerShell\tt.xml" -ea 0) {
		$hc | % {$_.commandline = @'
		"This is a test4"
		function F4 { "Function Test4"}
		$testclip = "Clip test4"
'@
		}

		$hc = import-clixml -first 1 "$Home\Documents\WindowsPowerShell\tt.xml"
		#$hid = ($hc | % {$_.commandline = gcb } | add-history -passthru).id; ihy $hid
	}
}

### gcb | % { $a = $_ -split '\.'; [array]::reverse($a); $a -join '.'}
  
#C:\Windows\Microsoft.NET\Framework64\v4.0.30319\config\machine.config
if ($psversiontable.psversion.major -lt 6) {
  [System.Runtime.InteropServices.RuntimeEnvironment]::SystemConfigurationFile
}


#> # End testing ideas


function Set-DefaultPropertySet { param([Object]$Object,
  [Alias('Properties','Property','Members')][string[]]$DefaultProperties)
  If (!$Object) { return $Null }
  $defaultDisplayPropertySet = 
    New-Object System.Management.Automation.PSPropertySet(
      'DefaultDisplayPropertySet',[string[]]$defaultProperties)
  $PSStandardMembers = 
    [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
  $OBject | Add-Member MemberSet PSStandardMembers $PSStandardMembers -PassThru
}

function Get-WinStaSession {
  [CmdletBinding()]param($UserName, [Alias('Me','My','Mine')][switch]$Current)
  $WinSta = qwinsta | select -skip 1
  write-verbose "Winsta count: $($WinSta.count)"
  $WinSta | % {
    write-verbose "WinStaLine: $_"
    # SESSIONNAME       USERNAME                 ID  STATE   TYPE        DEV
    # rdp-tcp#89        jramirez                 10  Active
    ForEach ($COL in @(2,19,56,68)) {
      $_ = $_ -replace "^(.{$($COL)})\s{3}", '$1###'
    }
    write-verbose "WinStaLine: $_"
    $S=[ordered]@{};
    $O=[ordered]@{};
    [boolean]$O.Current =  $_ -match '^>'
    $null,$S.Name,$S.UserName,$S.ID,$S.State,$S.Type,$S.Device,$null = $_ -split '[>\s]+'
    ForEach ($Key in $S.Keys) { $O.$Key = $S.$Key -replace '^###$' }    
    $SelectUser = [boolean]$UserName
    $Session = [PSCustomObject]$O
    if ($Current)    { $Session = $Session | ? Current  -eq    $True     }
    if ($SelectUser) { $Session = $Session | ? UserName -match $UserName }  
    if ($Session) { Set-DefaultPropertySet $Session @('Current','UserName','ID','State')}     
  }
}

#################################################################

$InformationPreference = 'continue'
write-information "$(LINE) InformationPreference: $InformationPreference"
write-information "$(LINE) Test hex format: $("{0:X}" -f -2068774911)"
# "{0:X}" -f -2068774911

function Get-DriveTypeName ($type) {
	$typename = @('UNKNOWN',     # 0 # The drive type cannot be determined.
					  		'NOROOTDIR',   # 1 # The root path is invalid; for example, there is no volume mounted at the specified path.
								'REMOVABLE',   # 2 # The drive has removable media; for example, a floppy drive, thumb drive, or flash card reader.
								'FIXED',       # 3 # The drive has fixed media; for example, a hard disk drive or flash drive.
								'REMOTE',      # 4 # The drive is a remote (network) drive.
								'CDROM',       # 5 # The drive is a CD-ROM drive.
								'RAMDISK')     # 6 # The drive is a RAM disk.
  if (($type -le 0) -or ($type -ge $typename.count)) {return 'INVALID'}
  $typename[$type]
}
function Get-Volume {
 (gwmi win32_volume ) | ? {$_.DriveLetter -match '[A-Z]:'}|
  % { "{0:2} {0:2} {0:9} {S:9} "-f $_.DriveLetter, $_.DriveType, (Get-DriveTypeName $_.DriveType), $_.Label, ($_.Freespace / 1GB)}
  # % {"$($_.DriveLetter) $($_.DriveType) $(Get-DriveTypeName $_.DriveType) $($_.Label) $($_.Freespace / 1GB)GB"}
}

function Get-WMIClassInfo {
  [CmdletBinding()] param([string]$className, [switch]$WrapList)
  #https://www.darkoperator.com/blog/2013/2/6/introduction-to-wmi-basics-with-powershell-part-2-exploring.html
  $r = (Get-WmiObject -list $className -Amended).qualifiers | Select-Object name, value
  if ($WrapList) { $r | ft -AutoSize -Wrap } else { $r }
}

function Get-DotNetAssembly  {
  [CmdletBinding()]param([string[]]$Include=@('.*'), [string[]]$Exclude=@('^$'), [switch]$full)
  $Inc = '(' + ($Include -join ')|(') + ')'
  $Exc = '(' + ($Exclude -join ')|(') + ')'
	write-verbose "Include: $Inc"
	write-verbose "Exclude: $Exc"
	[appdomain]::CurrentDomain.GetAssemblies() | ForEach {
		Try {
      # write-verbose "$($_.fullname)"
		  $_.GetExportedTypes() |
        Where { $_.fullname -match $inc } #-and $_.fullname -notmatch $Exc }
		} Catch  { write-verbose "CATCH: $($_.Fullname)"}
	} | % {if ($full) {$_} else { "$($_.fullname)" }}
}
function Get-DotNetAssembly  {
  [CmdletBinding()]param([string[]]$Include=@('.*'), [string[]]$Exclude=@('^$'), [switch]$full)
  $Inc = '(' + ($Include -join ')|(') + ')'
  $Exc = '(' + ($Exclude -join ')|(') + ')'
  write-verbose "Include: $Inc"
  write-verbose "Exclude: $Exc"
  [appdomain]::CurrentDomain.GetAssemblies() |
    ? { $_.fullname -match $inc } | #-and $_.fullname -notmatch $Exc } |
      % {
        write-verbose "$($_.fullname)"
        Try {
          if ($_.GetExportedTypes()) { $_ }
        } Catch  { } #write-verbose "CATCH: $($_.Fullname)" }
      } # | % {if ($full) {$_} else { "$($_.fullname)" }}.
}
function Get-DotNetAssembly  {
  [CmdletBinding()]param([string[]]$Include=@('.*'), [string[]]$Exclude=@('^$'), [switch]$full)
  $Inc = '(' + ($Include -join ')|(') + ')'
  $Exc = '(' + ($Exclude -join ')|(') + ')'
  write-verbose "Include: $Inc"
  write-verbose "Exclude: $Exc"
  write-verbose "Full: $([boolean]$full)"
  [appdomain]::CurrentDomain.GetAssemblies() | ? {
    $a = $_.fullname -match $inc -and $_.fullname -notmatch $Exc -and ($_.IsDynamic -or ($_.GetExportedTypes()))
    if ($full) { $a }
    else {
      $a | select GlobalAssemblyCache,IsDynamic,ImageRuntimeversion,Fullname,Location
    }
  }
}
    #  % {
    #    write-verbose "$($_.fullname)"
    #    Try {
    #      if ($_.GetExportedTypes()) { $_ }
    #    } Catch  { } #write-verbose "CATCH: $($_.Fullname)" }
    #  } # | % {if ($full) {$_} else { "$($_.fullname)" }}.
new-alias gdna Get-DotNetAssembly -force

function Get-Commandline {
  (get-history @args).commandline
} New-Alias cl Get-Commandline -force

new-alias gch Get-HistoryCommandLine -force
new-alias ghc Get-HistoryCommandLine -force
new-alias gcl Get-HistoryCommandLine -force
new-alias hcm Get-HistoryCommandLine -force
function get-syntax   { get-command -syntax @args }; new-alias syn get-syntax -force
function get-fullhelp { get-help -full @args }
'full','fh','fhelp','helpf' | % { new-alias $_ get-help -force -ea continue }

write-information "$(LINE) $home"
write-information "$(LINE) Try: import-module -prefix cx Pscx"
write-information "$(LINE) Try: import-module -prefix cb PowerShellCookbook"
#echo 'Install DOSKey'
#doskey /exename=powershell.exe /macrofile=c:\bat\macrosPS.txt
#del alias:where -ea 0
# Find-file
# where.exe autohotkey.exe 2>$Null
# $env:PathExt
function ahk {
  if ($args[0]) { C:\util\AutoHotKey\autohotkey.exe /r $args[0] }
  else          { C:\util\AutoHotKey\autohotkey.exe /r "c:\bat\ahk.ahk" }
}; new-alias a ahk -force

function ahk {
  [CmdletBinding()]param([string[]]$Path=@('c:\bat\ahk.ahk'))
  $argx = $args
  write-verbose "Path [$($Path -join '] [')] Argc $($argx.count): [$($args -join '], [')]"
  #if (!$argx.count) { $argx = [string[]]@('/r') }
  [string[]]$a = if ($argx.count) { $argx } else { @('/r') }
  write-verbose "ArgC: $($argx.count) [$($argx -join '], [')]"
  $path | % { C:\util\AutoHotKey\AutoHotkey.exe $_ @a }
}  New-Alias a ahk -force
function d   { cmd /c dir @args}
new-alias w  where.exe -force
#new-alias wh where.exe -force
function df  { dir @args -file }
function dfs { dir @args -file -rec }
function dd  { dir @args -dir  }
function dds { dir @args -dir  -rec }
function ddb { dir @args -dir       | select fullname}
function db  { dir @args            | select fullname }
function dsb { dir @args -rec       | select fullname}
function dfsb{ dir @args -rec -file | select fullname }
function dfp { d /a-@args d /b       | % {dir "$_"} }
function dod { dd @args | sort -lastwritetime }
function dfod {df @args | sort -lastwritetime }
function ddod {dd @args | sort -lastwritetime }
function od {
  param(
    [parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,
    ParameterSetName='Path')][Alias('pspath','fullname','filename')][object[]]$Path=@()
  )
  begin { $a=@(); $parent = ''}
  process {
    if ($parent -ne $path.psparent) {
      $a | sort @args lastwritetime,starttime
      $a = @()
    }
    $a += $path;
    $parent = $path.psparent;
  }
  end { $a | sort @args lastwritetime,starttime }
}
function os {
  param(
    [parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,
    ParameterSetName='Path')][Alias('pspath','fullname','filename')][object[]]$Path=@()
  )
  begin { $a=@(); $parent = ''}
  process {
    if ($parent -ne $path.psparent) {
      $a | sort-object length @args
      $a = @()
    }
    $a += $path;
    $parent = $path.psparent;
  }
  end { $a | sort-object length @args }
}
function cpy {cmd /c copy @args}
function mov {cmd /c move @args}
function fr  {cmd /c for @args}
function frf {cmd /c for /f @args}
function ff  {cmd /c for /f @args}
function Get-Drive {
  [CmdletBinding()] param(
    [string[]]$name='*',
	  [string]  $scope=1,
	  [string]  $PSProvider='FileSystem')
  get-psdrive -name $name -psprovider $psprovider -scope $scope
}

# https://poshtools.com/2018/02/17/building-real-time-web-apps-powershell-universal-dashboard/
# https://docs.microsoft.com/en-us/dotnet/api/?view=netframework-4.5
# function invoke-clipboard {$script = ((Get-Clipboard) -join "`n") -replace '(function\s+)', '$1 '; . ([scriptblock]::Create($script))}
#### Because of DIFFICULT with SCOPE
# $ProfileDirectory = Split-Path $Profile
$ICFile = "$ProfileDirectory\ic.ps1"
write-information "$(LINE) Create ic file: $ICFile"
set-content  $ICFile '. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))'
set-alias ic $ICFile -force -scope global -option AllScope
# get-uptime;Get-WURebootStatus;Is-RebootPending?;Get-Uptime;PSCx\get-uptime;boottime.cmd;uptime.cmd
# 
function Get-BootTime { (Get-CimInstance win32_operatingsystem).lastbootuptime }
write-information "$(LINE) Boot Time: $(Get-date ((Get-CimInstance win32_operatingsystem).lastbootuptime) -f 's')" 
function ql {  $args  }
function qs { "$args" }
function qa { 
  [CmdLetBinding(PositionalBinding=$False)]
  param(
    [Parameter()]$OFS=$(Get-Variable OFS -scope 1 -ea 0 -value),
    [Parameter()]$Quotes='',
    [Parameter()][switch]$DoubleQuote,
    [Parameter()][switch]$SingleQuote,
    [parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]$Args
  )
  begin {
    If ($DoubleQuote) { $Quotes = '"' }
    If ($SingleQuote) { $Quotes = "'" }
    if ($Quotes) { $OFS = $Quotes + $OFS + $Quotes }  
  }  
  process {    
    write-verbose "OFS: [$OFS] Length: $($OFS.Length) Count: $($OFS.Count) Quotes: [$Quotes]"
    "$Quotes$($(foreach ($a in $args) {if ($a -is [System.Array]) {qa @a } else {$a}} ) -join $OFS)$Quotes" 
  }
}

# $ic = [scriptblock]::Create('(Get-Clipboard) -join "`n"')
# $ic = '. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))'
# $ic = [scriptblock]::Create('. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))')

# https://weblogs.asp.net/jongalloway/working-around-a-powershell-call-depth-disaster-with-trampolines
write-information "$(LINE) Test-Administrator"
#function Test-Administrator { (whoami /all | select-string S-1-16-12288) -ne $null }
#if ((whoami /user /priv | select-string S-1-16-12288) -ne $null) {'Administrator privileges  enabled'} #else {'Administrator privileges NOT available'}

function Test-Administrator {
  ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
   [Security.Principal.WindowsBuiltInRole] "Administrator")
}
if ($AdminEnabled = Test-Administrator) {write-information "$(LINE) Administrator privileges  enabled"}
else {write-information "$(LINE) Administrator privileges NOT available"}

write-information "$(LINE) set Prompt function"
try {
  if (!$global:PromptStack) {
    #if ($global:PromptStack) -ne )
    [string[]]$global:PromptStack +=   (gcm prompt).ScriptBlock
	}
} catch {
	[string[]]$global:PromptStack  = @((gcm prompt).ScriptBlock)
}


write-information "$(LINE) Pushed previous prompt onto `$PromptStack: $($PromptStack.count) entries"
write-information "$(LINE) prompt='PS $($executionContext.SessionState.Path.CurrentLocation) $('>' * $nestedPromptLevel + '>')'"
#function Global:prompt { "PS '$($executionContext.SessionState.Path.CurrentLocation)' $('>.' * $nestedPromptLevel + '>') "}

function Global:prompt { "'$($executionContext.SessionState.Path.CurrentLocation)' |>$('>' * $nestedPromptLevel) "}

# function docs {
#   [CmdletBinding()]param (
#     [Parameter(Position='0')][string]$path="$Home\Documents",
#     [Parameter(Position='1')][string]$subdirectory,
#     [switch]$pushd
#   )
#   try {
#     write-verbose $Path
#     if (Test-Path $path) {
#       if ($pushd) { pushd $path } else { cd $path }
#       if ($subdirectory) {cd $subdirectory}
#     }	else {
#       throw "Directory [$Path] not found."
#     }
#   }	catch {
#     write-error $_
#   }
# }

# function books {
#   if (Test-Path "$($env:userprofile)\downloads\books") {
#     cd "$($env:userprofile)\downloads\books"
# 	} elseif (Test-Path "C:\books") {
#     cd "C:\books"
# 	}
# 	if ($args[0]) {cd $args[0]}
# }

$books = switch ($true) {
  { Test-Path 'c:\books' } { Resolve-Path 'c:\books' }
  { Test-Path (Join-Path (Join-Path $Home 'Downloads')  'Books') } { Resolve-Path (Join-Path (Join-Path $Home 'Downloads')  'Books') -ea 0 }
}

$gohash = [ordered]@{
  docs       = "$home\documents"
  down       = "$home\downloads"
  download   = "$home\downloads"
  downloads  = "$home\downloads"
  books      = $books
  powershell = "$books\PowerShell"
  profile    = $ProfileDirectory
  pro        = $ProfileDirectory
  txt        = 'c:\txt'
  text       = 'c:\txt'
  esb        = 'c:\esb'
  dev        = 'c:\dev'
}

function Set-GoAlias {
  [CmdletBinding()]param([string]$Alias, [string]$Path)
  if ($Alias) {
    if ($global:goHash.Contains($Alias)) { $global:goHash.Remove($Alias) }
    $global:goHash += @{$Alias = $path}
  }
  ForEach ($Alias in $goHash.Keys) {
    write-verbose "New-Alias $Alias go -force -scope Global -Option allscope"
    New-Alias $Alias Set-GoLocation -force -scope Global -Option allscope
  }
}

function Set-GoLocation {
  [CmdletBinding()]param (
    [Parameter(Position='0')][string[]]$path=@(),
    [Parameter(Position='1')][string[]]$subdirectory=@(),
    [switch]$pushd,
    [switch]$showInvocation   # for testing
  )
  $verbose = $true
  write-verbose "$(LINE) Start In: $((Get-Location).path)"
  if ($showInvocation) { write-warning "$($Myinvocation | out-string )" }
  $InvocationName = $MyInvocation.InvocationName
  if (Get-Command set-jumplocation -ea 0) {
           new-alias jpushd Set-JumpLocation -force
  } else { new-alias jpushd pushd            -force }
  if (!(get-variable gohash -ea 0)) { $goHash = @{} }
  write-verbose "$(LINE) Path: $Path InvocationName: $InvocationName"
  $subdir = @($subdirectory.foreach{$_.split(';')}) ##### $subdirectory -split ';'
  $Target = @(if ($goHash.Contains($InvocationName)) {
    if (!$subdirectory) { $subdir = @($path.foreach{$_.split(';')}) }
    $goHash.$InvocationName -split ';'
  } else {
    ForEach ($P in $Path) {
      if ($gohash.Contains($P)) { $gohash.$path.foreach{$_.split(';')} }  # @($goHash.path.foreach{$_.split(';')})
    }
  })
  if (!$Target ) { $Target = $Path.foreach{$_.split(';')} }
  write-verbose "$(LINE) path: [$($Target -join '] [')] sub: [$($subdir -join '] [')]"
  try {
    $ValidPath = @()
    :OuterForEach ForEach ($p in ($Target)) {    #  | % {$_ -split ';'}  ### @($path.foreach{$_.split(';')})
      if ($goHash.Contains($p) -and (Test-Path $goHash.$p)) { $p = $goHash.$p}
      write-verbose "$(LINE) Foreach P: $p"
      if (Test-Path $p -ea 0) {
        $ValidPath += Resolve-Path $p -ea 0
        ForEach ($Sub in ($subdir)) {   #  | % {$_ -split ';'}
          write-verbose "$(LINE) $p sub: $sub"
          $TryPath = Join-Path (Resolve-Path $pr -ea 0) $Sub
          if (Test-Path $TryPath) {
            $ValidPath = @(Resolve-Path (Join-Path $TryPath))
            write-verbose "$(LINE) Try: $TryPath ValidPath: [$($ValidPath -join '] [')]"
            break :OuterForEach
          }
        }
      }
    }
    if ($ValidPath) {
      write-verbose "$(LINE) Valid: $($ValidPath -join '; ')"
      if ($true -or $pushd) { jpushd  $ValidPath    }
      else        { cd      $ValidPath[0] }
    } else {
      write-verbose "$(LINE) $($Path -join '] [') $($Subdirectory -join '] [')"
      if ($Path -or $Subdirectory) {
        write-verbose "$(LINE) Jump: jpushd $(($Path + $Subdirectory) -join '; ')"
        jpushd ($Path + $Subdirectory)
      } else  {
        if ($InvocationName -notin 'go','g','Set-GoLocation','GoLocation') {
          write-verbose "$(LINE) Jump: jpushd $InvocationName"
          jpushd $InvocationName
        } else {
          jpushd $InvocationName
          write-verbose "$(LINE) Jump: jpushd $InvocationName"
        }
      }
    }
  }	catch {
    write-error $_
  }
  write-verbose "$(LINE) Current: $((Get-Location).path)"
} New-Alias Go Set-GoLocation -force -scope global; New-Alias G Set-GoLocation -force -scope global


Set-GoAlias

<#

Ok, I finally got around to starting to learn Pester version 4.1.1
PSVersion 5.1.14409.1012
Got this:
     Expected: {C:\books}
     But was:  {C:\books}
Looks like a match, editor says it's a match, so I tried adding the same test with just gettype() added to the test and should values, and it gave no error (though maybe it was not really 2 strings but just looked like strings. (edited)
(get-location).gettype();  (resolve-path .).gettype()
(get-location)  -eq (resolve-path .)
(get-location).path  -eq (resolve-path .).path

[-] Uses books to change directory to C:\books 90ms
  Expected: {C:\books}
  But was:  {C:\books}
  16:       & ([scriptblock]::Create("$Alias -verbose:$v -PushD"))  ; (get-location).path | Should -Be $goHash.$Alias
  at Invoke-Assertion, C:\Program Files\WindowsPowerShell\Modules\Pester\4.1.1\Functions\Assertions\Should.ps1: line 209
  at <ScriptBlock>, C:\Users\A469526\Documents\WindowsPowerShell\Go\GoLocation\GoLocation.Tests.ps1: line 16
#>

#new-alias docs       go -force
#new-alias books      go -force
#new-alias powershell go -force
#new-alias profile    go -force

# Utility Functions (small)
filter Is-Odd?  { param([Parameter(valuefrompipeline)][int]$n) [boolean]($n % 2)}
filter Is-Even? { param([Parameter(valuefrompipeline)][int]$n) -not (Is-Odd? $n)}
function get-syntax([string]$command='Get-Command') { if ($command) {gcm $command -syntax} }   # syntax get-command
new-alias syn get-syntax -force
function dump-object ($object, $depth=2) { $object | ConvertTo-Json -Depth $depth }
function dod { (dir @args) | sort -prop lastwritetime }
function don { (dir @args) | sort -prop fullname }
function dos { (dir @args) | sort -prop length }
function dox { (dir @args) | sort -prop extension }
function Test-Administrator { return (whoami /all | select-string S-1-16-12288) -ne $null }
function Privs? {
	if ((whoami /all | select-string S-1-16-12288) -ne $null) {
		'Administrator privileges  enabled'
	} else {
		'Administrator privileges NOT available'
	}
}

function Get-DayOfYear([DateTime]$date=(Get-Date)) {"{0:D3}" -f ($date).DayofYear}

function Get-FormattedDate ([DateTime]$Date = (Get-Date)) {
  Get-date "$date" ?f "yyyy-MM-ddTHH:mm:ss-ddd"
}
#([System.TimeZoneInfo]::Local.StandardName) -replace '([A-Z])\w+\s*', '$1'

function Get-SortableDate {
  [CmdletBinding()]param([DateTime]$Date = (Get-Date))
  Get-Date $date -format 's'
}

#$Myinvocation
#Resolve-Path $MyInvocation.MyCommand -ea 0
#if ($myinvocation.pscommandpath) {$myinvocation.pscommandpath}

#$PSReadLineProfile = Join-Path $myinvocation.pscommandpath 'PSReadLineProfile.ps1'
$PSReadLineProfile = Join-Path (Split-Path $Profile) 'PSReadLineProfile.ps1'
write-information $PSReadLineProfile
if (Test-Path $PSReadLineProfile) { . $PSReadLineProfile }

try {   # Chocolatey profile
  $ChocolateyProfile = "$($env:ChocolateyInstall)\helpers\chocolateyProfile.psm1"
  write-information "$(LINE) Chocolatey profile: $ChocolateyProfile"
  if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
  }
} catch {
  write-information "$(LINE) Chocolatey not available."
}

new-alias alias new-alias -force
new-alias 7z 'C:\util\7-Zip\App\7-Zip64\7z.exe' -force
function 4rank ($n, $d1, $d2, $d) {"{0:P2}   {1:P2}" -f ($n/$d),(1 - $n/$d)}
function Get-PSVersion {"$($psversiontable.psversion.major).$($psversiontable.psversion.minor)"}
write-information ("$(LINE) Use Function Get-PSVersion or variable `$PSVersionTable: $(Get-PSVersion)")
function down {cd "$env:userprofile\downloads"}
function Get-SerialNumber {gwmi win32_operatingsystem  | select -prop SerialNumber}
function Get-ComputerDomain { gwmi win32_computersystem | select-object -prop Name,Domain,DomainRole,DNSDomainName}
function drive {gwmi win32_logicaldisk | ? {$_.drivetype -eq 3} | % {"$($_.deviceid)\"}}
function fileformat([string[]]$path = @('c:\dev'), [string[]]$include=@('*.txt')) {
  dir -path $path -include $include -recurse -force -ea 0 |  Select-Object -prop basename,extension,@{Name='WriteTime';Expression={$_.lastwritetime -f "yyyy-MM-dd-ddd-HH:mm:ss"}},length,directory,fullname | export-csv t.csv -force
}
#region Script Diagnostic & utility Functions
#region Definitions
        # function Get-CurrentLineNumber
        # function Get-CurrentFileName
        # Alias   LINE    Get-CurrentLineNumber
        # Alias __LINE__  Get-CurrentLineNumber
        # Alias   FILE    Get-CurrentFileName
        # Alias __FILE__  Get-CurrentFileName
        # function write-log
        # function ExitWithCode($exitcode)
        # function Make-Credential
        # function Get-ErrorDetail
        # function MyPSHost
#endregion

function PSBoundParameter([string]$Parm) {
  return ($PSCmdlet -and $PSCmdlet.MyInvocation.BoundParameters[$Parm].IsPresent)
}

if (Get-Module 'PSReadline' -ea 0) {
  set-psreadlinekeyhandler -chord 'Tab'            -Func TabCompleteNext      ### !!!!!
  set-psreadlinekeyhandler -chord 'Shift+Tab'      -Func TabCompletePrevious  ### !!!!!
  set-psreadlinekeyhandler -chord 'Shift+SpaceBar' -Func Complete             ### !!!!!

  Set-PSReadlineOption -token string    -fore white 
  Set-PSReadlineOption -token None      -fore yellow
  Set-PSReadlineOption -token Operator  -fore cyan
  Set-PSReadlineOption -token Comment   -fore green
  Set-PSReadlineOption -token Parameter -fore green
  Set-PSReadlineOption -token Comment   -fore Yellow -back DarkBlue

	Set-PSReadLineOption -ForeGround Yellow  -Token None      
	Set-PSReadLineOption -ForeGround Green   -Token Comment   
	
	Set-PSReadLineOption -ForeGround Green   -Token Keyword   
	Set-PSReadLineOption -ForeGround Cyan    -Token String    
	Set-PSReadLineOption -ForeGround White   -Token Operator  
	Set-PSReadLineOption -ForeGround Green   -Token Variable  
	Set-PSReadLineOption -ForeGround Yellow  -Token Command   
	Set-PSReadLineOption -ForeGround Cyan    -Token Parameter 
	Set-PSReadLineOption -ForeGround White   -Token Type      
	Set-PSReadLineOption -ForeGround White   -Token Number    
	Set-PSReadLineOption -ForeGround White   -Token Member    

	$Host.PrivateData.ErrorBackgroundColor   = 'DarkRed'
	$Host.PrivateData.ErrorForegroundColor   = 'White'
	$Host.PrivateData.VerboseBackgroundColor = 'Black'
	$Host.PrivateData.VerboseForegroundColor = 'Yellow'
	$Host.PrivateData.WarningBackgroundColor = 'Black'
	$Host.PrivateData.WarningForegroundColor = 'White'
}


#---------------- Snippets
# cd (split-path -parent $profile )
# gcm *zip*,*7z*,*archive*  | ? {$_.Source -notmatch '\.(cmd|exe|bat)'}
<#
	$watcher = New-Object System.IO.FileSystemWatcher
	$watcher.Path = 'C:\temp\'
	$watcher.Filter = 'test1.txt'
	$watcher.EnableRaisingEvents = $true
	$changed = Register-ObjectEvent
	$watcher 'Changed' -Action {
	write-output "Changed: $($eventArgs.FullPath)"
}
#>
write-information "$(LINE) Error count: $($Error.Count)"

$utility = (('.;' + $env:path) -split ';' | % { join-path $_ 'utility.ps1' } | ? { test-path $_ -ea 0}) -split '\s*\n'
try {
  if ($utility) {
    write-information "$(LINE) Source: $utility"
    .  (Resolve-Path $utility[0]).path
    write-information "$(LINE) Finished sourcing: $utility"
  } else {
    write-information "$(LINE) utility.ps1 not found local or on path"
  }
} catch {
  write-information "$(LINE) Caught error importing $Utility"
  $_
}
#filter dt { if (get-variable _ -scope 0) { get-sortabledate $_ -ea 0 } else { get-sortabledate $args[1] } }
function dt {param([string[]]$datetime=(get-date)) $datetime | % { get-date $_ -format 'yyyy-MM-dd HH:mm:ss ddd' } }
#function dt {param([string[]]$datetime=(get-date)) $datetime | % { get-sortabledate $_) -creplace '\dT'  } }


function Find-File {
  [CmdletBinding()]param(
    [Parameter(Mandatory=$true)][string[]]$File,
    [string[]]$Location=@(($env:path -split ';') | select -uniq | ? { $_ -notmatch '^\s*$' }),
    [string[]]$Environment,
    [switch]$Recurse,
    [switch]$Details
  )

  Begin {
    $e = @{}
    function Extend-File {
      param([string]$name, [string]$ext="$($env:pathext);.PS1")
      If ($name -match '(\.[a-z0-9]{0,5})|\*$') {
        return @($name)
      } elseIf (!$e[$name]) {
        $e[$name] = @($ext -split ';' | select -uniq |
                  ? { $_ -notmatch '^\s*$' } | % { "$($Name)$_" })
      }
      $e[$name]
    }

    $Location += $Environment | % { $Location += ";$((dir -ea 0 Env:$_).value)" }
    If ($EPath) {$Location += ";$($Env:Path)"}
    $Location = $Location | % { $_ -split ';' } | select -uniq | ? { $_ -notmatch '^\s*$' }
    write-verbose ("$($Location.Count)`n" + ($Location -join "`n"))
    write-verbose ('-' * 72)
    write-verbose "Recurse: $Recurse"
  }

  Process {
    $File | % { $F=$_; ($Location | % {
      $L = $_; Extend-File $F |
      % { dir -file -ea 0 -recurse:$recurse (Join-Path $L $_) }
    })} | % {
      if ($Details) { $_ | select length,lastwritetime,fullname }
      else { $_.fullname }
    }
  }

  End { write-verbose ('-' * 72) }
}

function Make-Credential($username, $password) {
  $cred = $null
  $secstr = ConvertTo-SecureString -String $password -AsPlainText -Force
  if ($secstr) {
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$secstr
  }
  return $cred
}
function Get-ErrorDetail {
  param($ErrorRecord = $Error[0])
  $ErrorRecord | Format-List * -Force
  $ErrorRecord.InvocationInfo | Format-List *
  $Exception = $ErrorRecord.Exception
  for ($depth = 0; $Exception -ne $null; $depth++) {
    "$depth" * 80
    $Exception | Format-List -Force *
    $Exception = $Exception.InnerException
  }
}
function MyPSHost {
  $bit = if ([Environment]::Is64BitProcess) {'64-bit'} else {'32-bit'}
  If ($h = get-host) {
    return "$($h.name) $($h.version) $bit process"
  } else {
    return 'PowerShell host not found'
  }
}


Function Get-PSVersion {
  "$($psversiontable.psversion.major).$($psversiontable.psversion.minor)"
}


<#
General useful commands
 gcm *-rsjob*
 history[-10..-1]
#>
function PSBoundParameter([string]$Parm) {
  return ($PSCmdlet -and $PSCmdlet.MyInvocation.BoundParameters[$Parm].IsPresent)
}
#endregion Definitions
#endregion Script Diagnostic & utility Functions
#---------------- Snippets
# cd (split-path -parent $profile )
# gcm *zip*,*7z*,*archive*  | ? {$_.Source -notmatch '\.(cmd|exe|bat)'}
<#
	$watcher = New-Object System.IO.FileSystemWatcher
	$watcher.Path = 'C:\temp\'
	$watcher.Filter = 'test1.txt'
	$watcher.EnableRaisingEvents = $true
	$changed = Register-ObjectEvent
	$watcher 'Changed' -Action {
	write-output "Changed: $($eventArgs.FullPath)"
}
#>
write-host "`nError count: $($Error.Count)"
#if(Test-Path Function:\Prompt) {Rename-Item Function:\Prompt PrePoshGitPrompt -Force}


if ($Quiet -and $informationpreferenceSave) { $global:informationpreference = $informationpreferenceSave }

<#
Key                   Function                      Description                                                        
---                   --------                      -----------                                                        
Enter                 AcceptLine                    Accept the input or move to the next line if input is missing a ...
Shift+Enter           AddLine                       Move the cursor to the next line without attempting to execute t...
Ctrl+Enter            InsertLineAbove               Inserts a new empty line above the current line without attempti...
Ctrl+Shift+Enter      InsertLineBelow               Inserts a new empty line below the current line without attempti...
Escape                RevertLine                    Equivalent to undo all edits (clears the line except lines impor...
LeftArrow             BackwardChar                  Move the cursor back one character                                 
RightArrow            ForwardChar                   Move the cursor forward one character                              
Ctrl+LeftArrow        BackwardWord                  Move the cursor to the beginning of the current or previous word   
Ctrl+RightArrow       NextWord                      Move the cursor forward to the start of the next word              
Shift+LeftArrow       SelectBackwardChar            Adjust the current selection to include the previous character     
Shift+RightArrow      SelectForwardChar             Adjust the current selection to include the next character         
Ctrl+Shift+LeftArrow  SelectBackwardWord            Adjust the current selection to include the previous word          
Ctrl+Shift+RightArrow SelectNextWord                Adjust the current selection to include the next word              
UpArrow               HistorySearchBackward         Search for the previous item in the history that starts with the...
DownArrow             HistorySearchForward          Search for the next item in the history that starts with the cur...
Home                  BeginningOfLine               Move the cursor to the beginning of the line                       
End                   EndOfLine                     Move the cursor to the end of the line                             
Shift+Home            SelectBackwardsLine           Adjust the current selection to include from the cursor to the e...
Shift+End             SelectLine                    Adjust the current selection to include from the cursor to the s...
Delete                DeleteChar                    Delete the character under the cusor                               
Backspace             SmartBackspace                Delete previous character or matching quotes/parens/braces         
Ctrl+Spacebar         MenuComplete                  Complete the input if there is a single completion, otherwise co...
Tab                   TabCompleteNext               Complete the input using the next completion                       
Shift+Tab             TabCompleteNext               Complete the input using the next completion                       
Ctrl+a                SelectAll                     Select the entire line. Moves the cursor to the end of the line    
Ctrl+c                CopyOrCancelLine              Either copy selected text to the clipboard, or if no text is sel...
Ctrl+C                CopyAllLines                  Copies the all lines of the current command into the clipboard     
Ctrl+l                ClearScreen                   Clear the screen and redraw the current line at the top of the s...
Ctrl+r                ReverseSearchHistory          Search history backwards interactively                             
Ctrl+s                ForwardSearchHistory          Search history forward interactively                               
Ctrl+v                Paste                         Paste text from the system clipboard                               
Ctrl+x                Cut                           Delete selected region placing deleted text in the system clipboard
Ctrl+y                Redo                          Redo an undo                                                       
Ctrl+z                Undo                          Undo a previous edit                                               
Ctrl+Backspace        BackwardKillWord              Move the text from the start of the current or previous word to ...
Ctrl+Delete           KillWord                      Move the text from the cursor to the end of the current or next ...
Ctrl+End              ForwardDeleteLine             Delete text from the cursor to the end of the line                 
Ctrl+Home             BackwardDeleteLine            Delete text from the cursor to the start of the line               
Ctrl+]                GotoBrace                     Go to matching brace                                               
Ctrl+Alt+?            ShowKeyBindings               Show all key bindings                                              
Alt+.                 YankLastArg                   Copy the text of the last argument to the input                    
Alt+0                 DigitArgument                 Start or accumulate a numeric argument to other functions          
Alt+1                 DigitArgument                 Start or accumulate a numeric argument to other functions          
Alt+2                 DigitArgument                 Start or accumulate a numeric argument to other functions          
Alt+3                 DigitArgument                 Start or accumulate a numeric argument to other functions          
Alt+4                 DigitArgument                 Start or accumulate a numeric argument to other functions          
Alt+5                 DigitArgument                 Start or accumulate a numeric argument to other functions          
Alt+6                 DigitArgument                 Start or accumulate a numeric argument to other functions          
Alt+7                 DigitArgument                 Start or accumulate a numeric argument to other functions          
Alt+8                 DigitArgument                 Start or accumulate a numeric argument to other functions          
Alt+9                 DigitArgument                 Start or accumulate a numeric argument to other functions          
Alt+-                 DigitArgument                 Start or accumulate a numeric argument to other functions          
Alt+?                 WhatIsKey                     Show the key binding for the next chord entered                    
Alt+F7                ClearHistory                  Remove all items from the command line history (not PowerShell h...
F3                    CharacterSearch               Read a character and move the cursor to the next occurence of th...
Shift+F3              CharacterSearchBackward       Read a character and move the cursor to the previous occurence o...
F8                    HistorySearchBackward         Search for the previous item in the history that starts with the...
Shift+F8              HistorySearchForward          Search for the next item in the history that starts with the cur...
PageUp                ScrollDisplayUp               Scroll the display up one screen                                   
PageDown              ScrollDisplayDown             Scroll the display down one screen                                 
Ctrl+PageUp           ScrollDisplayUpLine           Scroll the display up one line                                     
Ctrl+PageDown         ScrollDisplayDownLine         Scroll the display down one line                                   
Shift+Spacebar        ExpandAlias                   Converts aliases into the resolved command / parameter             
F7                    History                       Show command history                                               
Ctrl+Alt+s            CaptureScreen                 Allows you to select multiple lines from the console using Shift...
Alt+d                 ShellKillWord                 Move the text from the cursor to the end of the current or next ...
Alt+Backspace         ShellBackwardKillWord         Move the text from the cursor to the start of the current or pre...
Alt+b                 ShellBackwardWord             Move the cursor to the beginning of the current or previous toke...
Alt+f                 ShellForwardWord              Move the cursor to the beginning of the next token or end of line  
Alt+B                 SelectShellBackwardWord       Adjust the current selection to include the previous word using ...
Alt+F                 SelectShellForwardWord        Adjust the current selection to include the next word using Shel...
"                     SmartInsertQuote              Insert paired quotes if not already on a quote                     
'                     SmartInsertQuote              Insert paired quotes if not already on a quote                     
(                     InsertPairedBraces            Insert matching braces                                             
{                     InsertPairedBraces            Insert matching braces                                             
[                     InsertPairedBraces            Insert matching braces                                             
)                     SmartCloseBraces              Insert closing brace or skip                                       
]                     SmartCloseBraces              Insert closing brace or skip                                       
}                     SmartCloseBraces              Insert closing brace or skip                                       
Alt+w                 SaveInHistory                 Save current line in history but do not execute                    
Ctrl+V                PasteAsHereString             Paste the clipboard text as a here string                          
Alt+(                 ParenthesizeSelection         Put parenthesis around the selection or entire line and move the...
Alt+'                 ToggleQuoteArgument           Toggle quotes on the argument under the cursor                     
Alt+%                 ExpandAliases                 Replace all aliases with the full command                          
F1                    CommandHelp                   Open the help window for the current command                       
Ctrl+J                MarkDirectory                 Mark the current directory                                         
Ctrl+j                JumpDirectory                 Goto the marked directory                                          
Alt+j                 ShowDirectoryMarks            Show the currently marked directories                              
Shift+Backspace       BackwardKillWord              Move the text from the start of the current or previous word to ...
Unbound               RepeatLastCommand             Repeats the last modification command.                             
Unbound               ViDigitArgumentInChord        Handles the processing of a number argument after the first key ...
Unbound               ViAcceptLineOrExit            If the line is empty, exit, otherwise accept the line as input.    
Unbound               ViInsertLine                  Inserts a new multi-line edit mode line in front of the current ...
Unbound               ViAppendLine                  Appends a new multi-line edit mode line to the current line.       
Unbound               ViJoinLines                   Joins the current multi-line edit mode line with the next.         
Unbound               ScrollDisplayTop              Scroll the display to the top                                      
Unbound               ScrollDisplayToCursor         Scroll the display to the cursor                                   
Unbound               UndoAll                       Undoes all commands for this line.                                 
Unbound               ViEditVisually                Invokes the console compatible editor specified by $env:VISUAL o...
Unbound               PasteAfter                    Write the contents of the local clipboard after the cursor.        
Unbound               PasteBefore                   Write the contents of the local clipboard before the cursor.       
Unbound               ViYankLine                    Place all characters in the current line into the local clipboard. 
Unbound               ViYankRight                   Place the character at the cursor into the local clipboard.        
Unbound               ViYankLeft                    Place the character to the left of the cursor into the local cli...
Unbound               ViYankToEndOfLine             Place all characters at and after the cursor into the local clip...
Unbound               ViYankPreviousWord            Place all characters from before the cursor to the beginning of ...
Unbound               ViYankNextWord                Place all characters from the cursor to the end of the word, as ...
Unbound               ViYankEndOfWord               Place the characters from the cursor to the end of the next word...
Unbound               ViYankEndOfGlob               Place the characters from the cursor to the end of the next whit...
Unbound               ViYankBeginningOfLine         Place the characters before the cursor into the local clipboard.   
Unbound               ViYankToFirstChar             Place all characters before the cursor and to the 1st non-white ...
Unbound               ViYankPercent                 Place all characters between the matching brace and the cursor i...
Unbound               ViYankPreviousGlob            Place all characters from before the cursor to the beginning of ...
Unbound               ViYankNextGlob                Place all characters from the cursor to the end of the word, as ...
Unbound               ViNextWord                    Move the cursor to the beginning of the next word, as delimited ...
Unbound               ViBackwardWord                Delete backward to the beginning of the previous word, as delimi...
Unbound               ViBackwardGlob                Move the cursor to the beginning of the previous word, as delimi...
Unbound               MoveToEndOfLine               Move to the end of the line.                                       
Unbound               NextWordEnd                   Moves the cursor forward to the end of the next word.              
Unbound               GotoColumn                    Moves the cursor to the perscribed column.                         
Unbound               GotoFirstNonBlankOfLine       Positions the cursor at the first non-blank character.             
Unbound               ViGotoBrace                   Move the cursor to the matching brace.                             
Unbound               Abort                         Abort the current operation, e.g. incremental history search       
Unbound               InvokePrompt                  Erases the current prompt and calls the prompt function to redis...
Unbound               RepeatLastCharSearch          Repeat the last recorded character search.                         
Unbound               RepeatLastCharSearchBackwards Repeat the last recorded character search in the opposite direct...
Unbound               SearchChar                    Move to the next occurance of the specified character.             
Unbound               SearchCharBackward            Move to the previous occurance of the specified character.         
Unbound               SearchCharWithBackoff         Move to he next occurance of the specified character and then ba...
Unbound               SearchCharBackwardWithBackoff Move to the previous occurance of the specified character and th...
Unbound               ViExit                        Exit the shell.                                                    
Unbound               DeleteToEnd                   Deletes from the cursor to the end of the line.                    
Unbound               DeleteWord                    Deletes the current word.                                          
Unbound               ViDeleteGlob                  Delete the current word, as delimited by white space.              
Unbound               DeleteEndOfWord               Delete to the end of the current word, as delimited by white spa...
Unbound               ViDeleteEndOfGlob             Delete to the end of this word, as delimited by white space.       
Unbound               ViCommandMode                 Switch to VI's command mode.                                       
Unbound               ViInsertMode                  Switches to insert mode.                                           
Unbound               ViInsertAtBegining            Moves the cursor to the beginning of the line and switches to in...
Unbound               ViInsertAtEnd                 Moves the cursor to the end of the line and switches to insert m...
Unbound               ViInsertWithAppend            Switch to insert mode, appending at the current line position.     
Unbound               ViInsertWithDelete            Deletes the current character and switches to insert mode.         
Unbound               ViAcceptLine                  Accept the line and switch to Vi's insert mode.                    
Unbound               PrependAndAccept              Inserts the entered character at the beginning and accepts the l...
Unbound               InvertCase                    Inverts the case of the current character and advances the cursor. 
Unbound               SwapCharacters                Swap the current character with the character before it.           
Unbound               DeleteLineToFirstChar         Deletes all of the line except for leading whitespace.             
Unbound               DeleteLine                    Deletes the current line.                                          
Unbound               BackwardDeleteWord            Delete the previous word in the line.                              
Unbound               ViBackwardDeleteGlob          Delete backward to the beginning of the previous word, as delimi...
Unbound               ViDeleteBrace                 Deletes all characters between the cursor position and the match...
Unbound               ViSearchHistoryBackward       Starts a new seach backward in the history.                        
Unbound               SearchForward                 Prompts for a search string and initiates a search upon AcceptLine.
Unbound               RepeatSearch                  Repeat the last search.                                            
Unbound               RepeatSearchBackward          Repeat the last search, but in the opposite direction.             
Unbound               CancelLine                    Abort editing the current line and re-evaluate the prompt          
Unbound               BackwardDeleteChar            Delete the charcter before the cursor                              
Unbound               DeleteCharOrExit              Delete the character under the cusor, or if the line is empty, e...
Unbound               ValidateAndAcceptLine         Accept the input or move to the next line if input is missing a ...
Unbound               AcceptAndGetNext              Accept the current line and recall the next line from history af...
Unbound               TabCompletePrevious           Complete the input using the previous completion                   
Unbound               Complete                      Complete the input if there is a single completion, otherwise co...
Unbound               PossibleCompletions           Display the possible completions without changing the input        
Unbound               ViTabCompleteNext             Invokes TabCompleteNext after doing some vi-specific clean up.     
Unbound               ViTabCompletePrevious         Invokes TabCompletePrevious after doing some vi-specific clean up. 
Unbound               PreviousHistory               Replace the input with the previous item in the history            
Unbound               NextHistory                   Replace the input with the next item in the history                
Unbound               BeginningOfHistory            Move to the first item in the history                              
Unbound               EndOfHistory                  Move to the last item (the current input) in the history           
Unbound               SetMark                       Mark the location of the cursor                                    
Unbound               ExchangePointAndMark          Mark the location of the cursor and move the cursor to the posit...
Unbound               KillLine                      Move the text from the cursor to the end of the input to the kil...
Unbound               BackwardKillLine              Move the text from the cursor to the beginning of the line to th...
Unbound               UnixWordRubout                Move the text from the cursor to the start of the current or pre...
Unbound               KillRegion                    Kill the text between the cursor and the mark                      
Unbound               Yank                          Copy the text from the current kill ring position to the input     
Unbound               YankPop                       Replace the previously yanked text with the text from the next k...
Unbound               YankNthArg                    Copy the text of the first argument to the input                   
Unbound               SelectForwardWord             Adjust the current selection to include the next word using Forw...
Unbound               SelectShellNextWord           Adjust the current selection to include the next word using Shel...
Unbound               Copy                          Copy selected region to the system clipboard.  If no region is s...
Unbound               PreviousLine                  Move the cursor to the previous line if the input has multiple l...
Unbound               NextLine                      Move the cursor to the next line if the input has multiple lines.  
Unbound               ShellNextWord                 Move the cursor to the end of the current token                    
Unbound               ForwardWord                   Move the cursor forward to the end of the current word, or if be...
#>

