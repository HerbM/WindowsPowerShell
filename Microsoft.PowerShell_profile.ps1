[CmdLetBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param(
  [Alias('Modules')][switch]$InstallModules,
  [ValidateSet('AllUsers','CurrentUser')][string]$ScopeModule='AllUsers',
  [switch]$ForceModuleInstall,
  [switch]$AllowClobber,
  [Alias('SilentlyContinue')][switch]$Quiet,
  [Parameter(ValueFromRemainingArguments=$true)][String[]]$RemArgs
)

$ForceModuleInstall = [boolean]$ForceModuleInstall
$AllowClobber       = [boolean]$AllowClobber
$Confirm            = [boolean]$Confirm

# new-alias np S:\Programs\Portable\Notepad++Portable\Notepad++Portable.exe -force -scope global
new-alias np S:\Programs\Portable\Notepad++Portable\Notepad++Portable.exe -force -scope global
function Select-History {param($Pattern) (h).commandline -match $Pattern }
new-alias sh Select-History -force -scope Global

# 'Thu, 08 Feb 2018 07:47:42 -0800 (PST)' -replace '[^\d]+$' -as [datetime] 13:47:42 -0800 (PST)'
# 'Thu, 08 Feb 2018 07:47:42 -0800 (PST)' -replace '[^\d]+$' -as [datetime] 13:47:42 -0800 (PST)'
#$raw = 'Thu, 08 Feb 2018 13:47:42 -0800 (PST)'
#$pattern = 'ddd, dd MMM yyyy H:mm:ss zzz \(PST)'
#[DateTime]::ParseExact($raw, $pattern, $null)

$MyInvocation
if ($MyInvocation.HistoryID -eq 1) {
  if (gcm write-information -type cmdlet,function -ea 0) {
    $InformationPreference = 'Continue'
    Remove-Item alias:write-information -ea 0
    $global:informationpreference = $warningpreference
  } else {
    write-warning 'Use write-warning for information if write-information not available'
    new-alias write-information write-warning -force # -option allscope
  }
}

if ($Quiet -and $global:informationpreference) {
  $informationpreferenceSave = $global:informationpreference
  $global:informationpreference = 'SilentlyContinue'
  $script:informationpreference = 'SilentlyContinue'
  write-information "SHOULD NOT WRITE"
}

$ProfilePath = Split-Path $Profile
write-information "Use `$Profile for path to Profile: $Profile"
# Chrome key mapper?  chrome://extensions/configureCommands
# Chrome extensions   chrome://extensions/

function Get-RunTime ($historyitem) { $historyitem.endexecutiontime - $historyitem.startexecutiontime }
new-alias np 'S:\Programs\Portable\Notepad++Portable\Notepad++Portable.exe' -force
new-alias 7z 'S:\Programs\Herb\util\7Zip\app\7-Zip64\7z.exe'                -force
get-itemproperty 'HKCU:\CONTROL PANEL\DESKTOP' -name WindowArrangementActive | Select WindowArrangementActive | FL
set-itemproperty 'HKCU:\CONTROL PANEL\DESKTOP' -name WindowArrangementActive -value 0 -type dword -force

# 7-Zip        http://www.7-zip.org/download.html
# Git          https://git-scm.com/download/win
# Regex        http://www.grymoire.com/Unix/Regular.html#uh-12
# AwkRef       http://www.grymoire.com/Unix/AwkRef.html
# Notepad++    https://notepad-plus-plus.org/download/v7.5.4.html
# ArsClip      http://www.joejoesoft.com/vcms/97/
# Aria2        https://github.com/aria2/aria2/releases/tag/release-1.33.1
# Deluge       http://download.deluge-torrent.org/windows/?C=M;O=D
# Transmission https://transmissionbt.com/download/
# WinMerg      http://developeronfire.com/blog/configuration-of-git-on-windows-to-make-life-easy
# NotesProfile See: NotesProfile.txt

write-information ".NET dotnet versions installed"
$DotNetKey = @('HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP',
               'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4')
@(foreach ($key in  $DotNetKey) { gci $key }) | get-itemproperty  -ea 0 | select @{N='Name';E={$_.pspath -replace '.*\\([^\\]+)$','$1'}},version,InstallPath,@{N='Path';E={($_.pspath -replace '^[^:]*::') -replace '^HKEY[^\\]*','HKLM:'}}

$PSGallery = Get-PSRepository PSGallery
$PSGallery
if ($PSGallery -and $PSGallery.InstallationPolicy -ne 'Trusted') {
  Set-PSRepository PSGallery -InstallationPolicy 'Trusted'
  Get-PSRepository PSGallery
}
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
  'PSReadLine'
)

# DSC_PowerCLISnapShotCheck  PowerCLITools  PowerCLI.SessionManager PowerRestCLI
# PowerShell CodeManager https://bytecookie.wordpress.com/
# ChocolateyGet


if ($InstallModules) {
  Install-ModuleList $RecommendedModules
} else {
  get-module -list $RecommendedModules
}
get-module -list | ? {$_.name -match 'PowerShellGet|PSReadline' -or $_.author -notmatch 'Microsoft' } |
  ft version,name,author,path

if ($psversiontable.psversion.major -lt 6) {
  Import-Module Jump.Location
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

#$MyInvocation
#$MyInvocation.MyCommand

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

<#
#>

write-information "Profile loaded: $($MyInvocation.MyCommand.Path)"

<#
[System.Windows.Forms.Screen]::AllScreens
[System.Windows.Forms.Screen]::PrimaryScreen
#>


################################################################

#if (gcm write-information -ea silentlycontinue) {
#	Remove-Item alias:write-information -ea 0
#	$global:informationpreference = $warningpreference
#} else {
#  write-warning 'Use write-warning for information if write-information not available'
#	set-alias write-information write-warning -force -option allscope
#}

<#
ts.ecs-support.com:32793  terminal server 10.10.11.80
ts.ecs-support.com:32795 FS02
#>
$j1 = $ecsts01 = 'ts.ecs-support.com:32793'
$j2 = $ecsts02 = 'ts.ecs-support.com:32795'

function RDP {
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
}

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
function invoke-clipboard {$script = ((Get-Clipboard) -join "`n") -replace '(function\s+)', '$1 '; . ([scriptblock]::Create($script))}
#### Because of DIFFICULT with SCOPE
write-information "$(LINE) Create ic.ps1"
if (Test-Path c:\bat\ic.ps1) {
  set-content c:\bat\ic.ps1 '. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))'
}
$ic = [scriptblock]::Create('(Get-Clipboard) -join "`n"')
$ic =  '. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))'
$ic =  [scriptblock]::Create('. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))')

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

function Global:prompt { "'$($executionContext.SessionState.Path.CurrentLocation)' PS>$('>' * $nestedPromptLevel) "}

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
  profile    = $ProfilePath
  pro        = $ProfilePath
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
new-alias np C:\util\notepad++.exe -force
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

$utility = (('.;' + $env:path) -split ';' | % { join-path $_ 'utility.ps1' } | ? { test-path $_ }) -split '\s*\n'
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

function Get-CurrentLineNumber { $MyInvocation.ScriptLineNumber }
function Get-CurrentFileName   { $MyInvocation.MyCommand.Name   }   #$MyInvocation.ScriptName
Set-Alias -Name   LINE   -Value Get-CurrentLineNumber -Description "Returns the current (caller's) line number in a script." -force -option allscope
Set-Alias -Name __LINE__ -Value Get-CurrentLineNumber -Description "Returns the current (caller's) line number in a script." -force -option allscope
Set-Alias -Name   FILE   -Value Get-CurrentFileName   -Description 'Returns the name of the current script file.'             -force -option allscope
Set-Alias -Name __FILE__ -Value Get-CurrentFileName   -Description 'Returns the name of the current script file.'             -force -option allscope
"$(FILE) test "
function write-log {
  param (
    [Parameter(Mandatory=$true)][string]$Message,
    [Parameter()][ValidateSet('1','2','3')][int]$Severity = 1 ## Default to a low severity. Otherwise, override
  )
  write-verbose $Message
  $line = [pscustomobject]@{
    'DateTime' = (Get-Date)
    'Severity' = $Severity
    'Message'  = $Message
  }
  if (-not $LogFilePath) {
    $LogFilePath = '.\LogFile.txt'
  }
  $line | Export-Csv -Path $LogFilePath -Append -NoTypeInformation -erroraction Silentlycontinue -force
}
function ExitWithCode($exitcode) {
  $host.SetShouldExit($exitcode)
  exit
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
