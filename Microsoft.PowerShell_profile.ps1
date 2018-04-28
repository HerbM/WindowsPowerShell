[CmdLetBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
  param (
    [Alias('DotNet')]                                    [switch]$ShowDotNetVersions,
    [Alias('Modules')]                                   [switch]$ShowModules,
    [Alias('IModules')]                                  [switch]$InstallModules,
                                                         [switch]$ForceModuleInstall,
    [ValidateSet('AllUsers','CurrentUser')]              [string]$ScopeModule='AllUsers',
    [Parameter(ValueFromRemainingArguments=$true)]       [string[]]$RemArgs,
    [Alias('ClobberAllowed')]                            [switch]$AllowClobber,
    [Alias('SilentlyContinue')]                          [switch]$Quiet,
    [Alias('PSReadlineProfile','ReadlineProfile','psrl')][switch]$PSReadline,
    [Alias('ForcePSReadlineProfile','fpsrl')]            [switch]$ForcePSReadline
    #[Alias('IAc','IAction','InfoAction')]
    #[ValidateSet('SilentlyContinue','')]                                  [switch]$InformationAction
  )


Function Get-CurrentLineNumber { $MyInvocation.ScriptLineNumber }
New-Alias -Name LINE -Value Get-CurrentLineNumber -Description 'Returns the caller''s current line number' -force -Scope Global -Option allscope
write-warning "$(get-date -f 'HH:mm:ss') $(LINE) PowerShell $($psversiontable.PSVersion.tostring())"


  # 'Continue', 'Ignore', 'Inquire', 'SilentlyContinue', 'Stop', 'Suspend' #'Continue'          'Inquire'           'Stop'
  # 'Ignore'            'SilentlyContinue'  'Suspend'

  # Fixed Alt+(,Alt+),Get-DotNetAssembly,Get-RunTime,Add Get-Accelerator,[Accelerators]
  # Temporary Fix to Go(works without Jump), Scripts to path,find and run Local*.ps1"
  # Fix 6.0 problems, PSGallery, Where.exe output, PSProvider,Jump.Location load
  # Improved Get-ChildItem2, Add-ToolPath,++B,++DosKey,CleanPath,start Get-DirectoryListing,add refs,README.mkdir
  # Show-ConsoleColor,Get-Syntax(aliases),++Select-History,++FullHelp,++d cmds, esf (needs *,? support),++Add-ToolPath,Reduce History Saved
  # Started Add-Path(crude) -- more ToDo notes

  # ToDo: Add support for local-only PS1 files -- started
  # ToDo: Move notes out of this file
  # ToDo: Test without Admin privs and skip issues -- partial
  # ToDo: Add Update-Help as background job?
  # ToDo: Updrade PowerShell to 5.1+
  # ToDo: Set console colors?  DarkGray = 80 80 80?
  # ToDo: JOIN-PATH -resolve:  NOT Test-Path -resolve , Add Server to Get-WinStaSession
  # ToDo: improve go, find alias Version numbers (at least display)
  # ToDo: need Notepad++, 7zip, Git, ??? to be on path with shortcuts (improved, not good enough yet)
  # ToDo: LogFile was being written, written now, CHECK?
  # ToDo: Clean up output -- easier to read, don't use "warnings" (colors?)
  # ToDo: Setup website for initial BootStrap scripts to get tools, Profile etc.
  #         Run scripts from "master" ????
  #         Download Tools -- as job
  #         Sync tools -- as job or scheduled job?
  #         Git, Enable Scripting/Remoting etc.,
  #         Configure new build, Firewall off,RDP On,No IPv6 etc
  #         Split out functions etc to "Scripts" directory
  #         Speed up History loading?
  #         get-process notepad++ | Select-Object name,starttime,productversion,path
  #         Get-WMIObject win32_service -filter 'name = "everything"' | Select-Object name,StartMode,State,Status,Processid,StartName,DisplayName,PathName | Format-Table


  # Git-Windows Git (new file), previous commit worked on JR 2 machines
  # Improve goHash, Books & Dev more general, fix S: T: not found
  # Everything? es?
  # Add rdir,cdir,mdir aliases
  # Close with Set-ProgramAlias
  # Add new set-programalias nscp 'C:\Program Files\NSClient++\nscp.exe' -force -scope
  # Fix RDP alias, Put 7-zip, Util,Unx in S:\Programs, New program searcher?  Better?
  # Boottime,ProfilePath moved up,LINE/FILE/Write-LOG,LogFilePath?,7z
  # Add/fix BootTime Function
  # Move $PSProfileDirectory up
  # Move utility extract up (LINE, FILE, WRITE-LOG)
  # working on LogFilePath
  # worked on 7z  --

  # Jing imagex sharex
  # C:\Program Files\ShareX\ & 'C:\Program Files\ShareX\ShareX.exe'
  #   https://getsharex.com/docs/amazon-s3
  # PowerShell Windows Management Framework 5.1 https://www.microsoft.com/en-us/download/details.aspx?id=54616
  #   W2K12-KB3191565-x64.msu
  #   Win7AndW2K8R2-KB3191566-x64.zip
  #   Win7-KB3191566-x86.zip
  #   Win8.1AndW2K12R2-KB3191564-x64.msu
  #   Win8.1-KB3191564-x86.msu
  # Delete multiple downloads with parenthesis numbers
  #   Get-ChildItem '*([1-9]).*' | Sort-Object name | ForEach-Object { if (Test-Path ($F0=$($_.FullName -replace '\s+\(\d+\)'))) { write-host "Ok: $F0" -fore Green -back 'Black' ; "del $($_.FullName)" } }
  # Interact with Symbolic links using improved Item cmdlets
  #   https://docs.microsoft.com/en-us/powershell/wmf/5.0/feedback_symbolic
  # How To Set Up Chocolatey For Organizational/Internal Use
  #   https://chocolatey.org/docs/how-to-setup-offline-installation

  # https://null-byte.wonderhowto.com/how-to/use-google-hack-googledorks-0163566/
  # 7-Zip        http://www.7-zip.org/download.html
  # Git          https://git-scm.com/download/win
  #              https://github.com/git-for-windows/git/releases/download/v2.16.2.windows.1/Git-2.16.2-64-bit.exe
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
  # WinMerge     http://developeronfire.com/blog/configuration-of-git-on-windows-to-make-life-easy
  # NotesProfile See: NotesProfile.txt
  # docker       https://docs.docker.com/install/windows/docker-ee/#use-a-script-to-install-docker-ee
  #              https://github.com/wsargent/docker-cheat-sheet
  # Wakoopa      https://web.appstorm.net/how-to/app-management-howto/how-to-discover-new-apps-with-wakoopa/
  #


$ProfileDirectory   = Split-Path $Profile
$PSProfile          = $MyInvocation.MyCommand.Definition
$PSProfileDirectory = Split-Path $PSProfile
$ProfileLogPath = $Profile -replace '\.ps1$','LOG.txt'
write-information "$(LINE) Use `$Profile   for path to Profile: $Profile"
write-information "$(LINE) Use `$PSProfile for path to Profile: $PSProfile"
Write-Information "$(LINE) ProfileLogPath: $ProfileLogPath"

try {
  $ProfileScriptDirectories = $ProfileDirectory, $PSProfileDirectory,
            "$ProfileDirectory\Scripts*", "$PSProfileDirectory\Scripts*"
  Join-Path $ProfileScriptDirectories Local*.ps1 -resolve -ea 0 2>$Null |
    Select-Object -uniq | ForEach-Object {
    try {
      . $_  2>&1
    } catch {
      write-warning "1: Caught error in loading local profile scripts: $_ "
    }
  }
} catch {
  write-warning "2: Caught error in loading local profile scripts"
}

try {
  #Clean the $Env:Path
  $SavePath = ($Env:Path -split ';' -replace '(?<=[\w\)])[\\;\s]*$' |
  Where-Object { $_ -and (Test-Path $_) } | Select-Object -uniq) -join ';'
  if ($SavePath) { $Env:Path, $SavePath = $SavePath, $Env:Path }
  Function Get-PSVersion {"$($psversiontable.psversion.major).$($psversiontable.psversion.minor)"}

  Function Test-Administrator {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
     [Security.Principal.WindowsBuiltInRole] "Administrator")
  }
  #write-information "$(LINE) Test-Administrator: $(Test-Administrator)"
  #Function Test-Administrator { (whoami /all | Select-Object -string S-1-16-12288) -ne $null }
  #if ((whoami /user /priv | Select-Object -string S-1-16-12288) -ne $null) {'Administrator privileges: ENABLED'} #else {'Administrator privileges: DISABLED'}
  if ($AdminEnabled = Test-Administrator) {
           write-information "$(LINE) Administrator privileges enabled"
  } else { write-information "$(LINE) Administrator privileges DISABLED"}

# Add to Scripts, Snippets etc.
# Fix 6.0 problems, PSGallery, Where.exe output, PSProvider,Jump.Location load
# Improved Get-ChildItem2, Add-ToolPath,++B,++DosKey,CleanPath,start Get-DirectoryListing,add refs,README.md
# Show-ConsoleColor,Get-Syntax(aliases),++Select-History,++FullHelp,++d cmds, esf (needs *,? support),++Add-ToolPath,Reduce History Saved
# Started Add-Path(crude) -- more ToDo notes

# ToDo: Put scripts on path
# ToDo: Move notes out of this file, Use Misc1/Work Misc/Home
# ToDo: Test without Admin privs and skip issues
# ToDo: Add Update-Help as background job?
# ToDo: Updrade PowerShell to 5.1+
# ToDo: Set console colors?  DarkGray = 80 80 80?
# ToDo: JOIN-PATH -resolve:  NOT Test-Path -resolve , Add Server to Get-WinStaSession
# ToDo: improve go, find alias Version numbers (at least display)
# ToDo: need Notepad++, 7zip, Git, ??? to be on path with shortcuts (improved, not good enough yet)
# ToDo: LogFile was being written, written now, CHECK?
# ToDo: Clean up output -- easier to read, don't use "warnings" (colors?)
# ToDo: Setup website for initial BootStrap scripts to get tools, Profile etc.
#         Run scripts from "master" ????
#         Download Tools -- as job
#         Sync tools -- as job or scheduled job?
#         Git, Enable Scripting/Remoting etc.,
#         Configure new build, Firewall off,RDP On,No IPv6 etc
#         Split out functions etc to "Scripts" directory
#         Speed up History loading?
#         get-process notepad++ | select name,starttime,productversion,path
#         gwmi win32_service -filter 'name = "everything"' | select name,StartMode,State,Status,Processid,StartName,DisplayName,PathName | ft


# Git-Windows Git (new file), previous commit worked on JR 2 machines
# Improve goHash, Books & Dev more general, fix S: T: not found
# Everything? es?
# Add rdir,cdir,mdir aliases
# Close with Set-ProgramAlias
# Add new set-programalias nscp 'C:\Program Files\NSClient++\nscp.exe' -force -scope
# Fix RDP alias, Put 7-zip, Util,Unx in S:\Programs, New program searcher?  Better?
# Boottime,ProfilePath moved up,LINE/FILE/Write-LOG,LogFilePath?,7z
# Add/fix BootTime function
# Move $PSProfileDirectory up
# Move utility extract up (LINE, FILE, WRITE-LOG)
# working on LogFilePath
# worked on 7z  --
write-warning "$(get-date -f 'HH:mm:ss') $(LINE)"

# Jing imagex sharex
# C:\Program Files\ShareX\ & 'C:\Program Files\ShareX\ShareX.exe'
#   https://getsharex.com/docs/amazon-s3
# PowerShell Windows Management Framework 5.1 https://www.microsoft.com/en-us/download/details.aspx?id=54616
#   W2K12-KB3191565-x64.msu
#   Win7AndW2K8R2-KB3191566-x64.zip
#   Win7-KB3191566-x86.zip
#   Win8.1AndW2K12R2-KB3191564-x64.msu
#   Win8.1-KB3191564-x86.msu
# Delete multiple downloads with parenthesis numbers
#   dir '*([1-9]).*' | sort name | % { if (Test-Path ($F0=$($_.FullName -replace '\s+\(\d+\)'))) { write-host "Ok: $F0" -fore Green -back 'Black' ; "del $($_.FullName)" } }
# Interact with Symbolic links using improved Item cmdlets
#   https://docs.microsoft.com/en-us/powershell/wmf/5.0/feedback_symbolic
# How To Set Up Chocolatey For Organizational/Internal Use
#   https://chocolatey.org/docs/how-to-setup-offline-installation
# C:\ProgramData\Ditto\Ditto.exe
# 'C:\Program Files\WinMerge2011\WinMergeU.exe'
#
If ($WinMerge = Join-Path -resolve -ea 0 'C:\Program*\WinMerge*' 'WinMerge*.exe' |
  ? { $_ -notmatch 'proxy' } | select -first 1) {
  new-alias WinMerge $WinMerge -force -scope Global
}
# https://null-byte.wonderhowto.com/how-to/use-google-hack-googledorks-0163566/
# 7-Zip        http://www.7-zip.org/download.html
# Git          https://git-scm.com/download/win
#              https://github.com/git-for-windows/git/releases/download/v2.16.2.windows.1/Git-2.16.2-64-bit.exe
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
# WinMerge     http://developeronfire.com/blog/configuration-of-git-on-windows-to-make-life-easy
# NotesProfile See: NotesProfile.txt
# docker       https://docs.docker.com/install/windows/docker-ee/#use-a-script-to-install-docker-ee
#              https://github.com/wsargent/docker-cheat-sheet
# Wakoopa      https://web.appstorm.net/how-to/app-management-howto/how-to-discover-new-apps-with-wakoopa/
# ArsClip

#Clean the $Env:Path
$SavePath = ($Env:Path -split ';' -replace '(?<=[\w\)])[\\;\s]*$' |
             Where-Object { $_ -and (Test-Path $_) } |
             select -uniq) -join ';'
if ($SavePath) { $Env:Path, $SavePath = $SavePath, $Env:Path }
function Get-PSVersion {"$($psversiontable.psversion.major).$($psversiontable.psversion.minor)"}

Function Add-ToolPath {
  [CmdLetBinding()]param(
    [string[]]$Path
  )
  ForEach ($TryPath in $Path) {
    if ($marker = where.exe PortCheck.exe 2>&1) {
      Write-Warning "Path is good: $marker"
      return
    } else {
      if (Test-Path (Join-Path $TryPath "Util\PortCheck.exe" -ea 0)) {
        $addpath = ";$TryPath\util;$TryPath\Unx;$\TryPath\Bat"
        $Global:Env:Path += $addpath
        Write-Warning "Added: $addpath"
        $Global:Env:Path >$Null
        return
      }
    }
  }
  Write-Warning "Unabled to put tools on path: PortCheck.exe"
}

write-warning "$(get-date -f 'HH:mm:ss') $(LINE)"
$PlacesToLook = 'C:\','T:\Programs\Herb','T:\Programs\Tools','T:\Programs',
                'S:\Programs\Tools','S:\Programs\Herb''S:\Programs'        |
                Where-Object  { Test-Path $_ -ea 0 }
try { Add-ToolPath $PlacesToLook } catch { Write-Warning "Caught:  Add-Path"}

Function DosKey {
  param($Pattern='=')
  if ($macros = where.exe 'macros.txt' 2>$Null) {
    Get-Content $macros | Where-Object { $_ -match $Pattern }
  }
}
Function B { if (!$Args) { $args = ,95}  DisplayBrightnessConsole @Args }

<#
Function Add-Path {
  [CmdLetBinding()]param(
    [string[]]$Path
  )
  $SpltPath = $Env:Path -split ';'
  ForEach ($Get-ChildItem in Path) {
    $Get-ChildItem = Split-Path -leaf $Get-ChildItem -ea 0 # get just final directory name
    $OnPath = $SplitPath -match "\\$Get-ChildItem$"
    $OnPath =
    #If (! ())
    if (!(Test-Path 'C:\Util')) {
      # $env:path += ';T:\Programs\Herb\util;T:\Programs\Herb\Unx;T:\programs\Herb\Bat'

    }
  }
}
#>

# "line1","line2" -join (NL)
# "line1","line2" -join [environment]::NewLine
# https://github.com/FriedrichWeinmann/PSReadline-Utilities
# https://github.com/FriedrichWeinmann/functions
# PSFramework
# Install-Module -Scope CurrentUser -Name Assert
# Chrome key mapper?  chrome://extensions/configureCommands
# Chrome extensions   chrome://extensions/
write-warning "$(get-date -f 'HH:mm:ss') $(LINE)"
Function Get-NewLine { [environment]::NewLine }; new-alias NL Get-NewLine -force
if (! (Get-Command write-log -type Function,cmdlet,alias -ea 0)) {
  new-alias write-log write-verbose -force -scope Global -ea 0
}
new-alias kp      'C:\Program Files (x86)\KeePass2\KeePass.exe' -force -scope Global
new-alias KeePass 'C:\Program Files (x86)\KeePass2\KeePass.exe' -force -scope Global
new-alias rdir    Remove-Item  -force -scope Global -ea 0
new-alias cdir    Set-Location -force -scope Global -ea 0
new-alias mdir    mkdir        -force -scope Global -ea 0
new-alias modir   modir        -force -scope Global -ea 0
new-alias moredir modir        -force -scope Global -ea 0
new-alias tdir    Get-Content  -force -scope Global -ea 0
new-alias typedir Get-Content  -force -scope Global -ea 0
new-alias ldir    less         -force -scope Global -ea 0
new-alias lessdir less         -force -scope Global -ea 0
new-alias l       less         -force -scope Global -ea 0

write-warning "$(get-date -f 'HH:mm:ss') $(LINE)"

try {
  $TryPath = $PSProfileDirectory,$ProfileDirectory,'C:\Bat' |
    Where-Object { Test-Path $_ -ea 0 }
  Write-Warning "$(LINE) Try Utility path: $($TryPath -join '; ')"
  if ($Util=@(Join-Path $TryPath 'utility.ps1' -ea 0)) {
    Write-Warning "Utility: $($Util -join '; ')"
    . $Util[0]
    Write-Log "$(LINE) Using Write-Log from Utility.ps1" -file $ProfileLogPath 3
  }
} catch { # just ignore and take care of below
  Write-Log "Failed loading Utility.ps1" -file $PSProfileLogPath 3
} finally {}

write-warning "$(get-date -f 'HH:mm:ss') $(LINE) ##338"

if ((Get-Command 'Write-Log' -type Function,cmdlet -ea 0)) {
  remove-item alias:write-log -force -ea 0
} else {
  New-Alias Write-Log Write-Verbose -ea 0
  Write-Warning "$(LINE) Utility.ps1 not found.  Defined alias for Write-Log"
<#  Function Get-CurrentLineNumber { $MyInvocation.ScriptLineNumber }
  Function Get-CurrentFileName   { split-path -leaf $MyInvocation.PSCommandPath   }   Function Get-CurrentFileLine   {
    if ($MyInvocation.PSCommandPath) {
      "$(split-path -leaf $MyInvocation.PSCommandPath):$($MyInvocation.ScriptLineNumber)"
    } else {"GLOBAL:$(LINE)"}
  }
  Function Get-CurrentFileName1  {
    if ($var = get-variable MyInvocation -scope 1 -value) {
      if ($var.PSCommandPath) { split-path -leaf $var.PSCommandPath }
      else {'GLOBAL'}
    } else {"GLOBAL"}
  }   #$MyInvocation.ScriptName
#>
#  New-Alias -Name   LINE   -Value Get-CurrentLineNumber -Description 'Returns the current (caller''s) line number in a script.' -force -Option allscope
#  New-Alias -Name   FILE   -Value Get-CurrentFileName   -Description 'Returns the name of the current script file.' -force             -Option allscope
#  New-Alias -Name   FLINE  -Value Get-CurrentFileLine   -Description 'Returns the name of the current script file.' -force             -Option allscope
#  New-Alias -Name   FILE1  -Value Get-CurrentFileName1  -Description 'Returns the name of the current script file.' -force             -Option allscope
#  remove-item alias:write-log -force -ea 0
# Function Write-Log {
#   param (
#     [string]$Message,
#     [int]$Severity = 3, ## Default to a high severity. Otherwise, override
#     [string]$File
#   )
#   try {
#     if (!$LogLevel) { $LogLevel = 3 }
#     if ($Severity -lt $LogLevel) { return }
#     write-verbose $Message
#     $line = [pscustomobject]@{
#       'DateTime' = (Get-Date -f "yyyy-MM-dd-ddd-HH:mm:ss") #### (Get-Date)
#       'Severity' = $Severity
#       'Message'  = $Message
#     }
#     if (-not $LogFilePath) {
#       $LogFilePath  =  "$($MyInvocation.ScriptName)" -replace '(\.ps1)?$', ''
#       $LogFilePath += '-Log.txt'
#     }
#     if ($File) { $LogFilePath = $File }
#     if ($psversiontable.psversion.major -lt 3) {
#       $Entry = "`"$($line.DateTime)`", `"$($line.$Severity)`", `"$($line.$Message)`""
#       $null = Out-file -enc utf8 -filepath $LogFilePath -input $Entry -append -erroraction Silentlycontinue -force
#     } else {
#       $line | Export-Csv -Path $LogFilePath -Append -NoTypeInformation -erroraction Silentlycontinue -force -enc ASCII
#     }
#   } catch {
#     $ec   = ('{0:x}' -f $_.Exception.ErrorCode); $em = $_.Exception.Message; $in = $_.InvocationInfo.PositionMessage
#     $description =  "$(LINE) Catch $in $ec, $em"
#     "Logging: $description" >> $LogFilePath
#   }
# }
#
# Function LINE {
#   param ([string]$Format,[switch]$Label)
#   $Line = '[1]'; $Suffix = ''
#   If ($Format) { $Label = $True }
#   If (!$Format) { $Format = 'Line {0,3}:' }
#   try {
#     if (($L = get-variable MyInvocation -scope 1 -value -ea 0) -and $L.ScriptLineNumber) {
#       $Line = $L.ScriptLineNumber
#     }
#   } catch {
#     $Suffix = '(Catch in LINE)'
#   }
#   if ($Label) { $Line = $Format -f $Line }
#   "$Line$Suffix"
# }
}

<#
#>

write-information "Profile loaded: $($MyInvocation.MyCommand.Path) ##416"

$PSVersionNumber = "$($psversiontable.psversion.major).$($psversiontable.psversion.minor)" -as [double]
write-information "$(LINE) PowerShell version PSVersionNumber: [$PSVersionNumber]"

$ForceModuleInstall = [boolean]$ForceModuleInstall
$AllowClobber       = [boolean]$AllowClobber
$Confirm            = [boolean]$Confirm

# 'C:\util\notepad++.exe' -force
# 'S:\Programs\Portable\Notepad++Portable\Notepad++Portable.exe' -force -scope global
# 'C:\Program Files (x86)\Notepad++\Note*.exe'   # ECS-DCTS02  Dec 2017 7.5.4
#  S:\Programs\Notepad++ # 1/2/2018 Notepad++Portable.exe
#  S:\Programs\Notepad++\app\Notepad++\   # Dec 2017
#  S:\Programs\Herb\util\notepad++Portable.exe

### $SearchNotePadPlusPlus = @('S:\Programs' )
<#
$NotepadPlusPlus = (
  @((get-childitem 'ENV:Notepad++','ENV:NotepadPlusPlus' -ea 0).value -split ';'  |
    Where-Object { $_ -match '\S'} |
    ForEach-Object { $_,(Join-Path $_ 'Notepad++*'  2>$Null)} | Where-Object {Test-Path $_ -ea 0})      +
  (where.exe notepad++ 2>$null)                                +
  (gal np -ea 0).definition                                    +
  ((get-childitem ENV:prog* -ea 0).value | Select-Object -uniq        |
    ForEach-Object {Join-Path $_ 'Notepad++*'} | Where-Object {Test-Path $_ -ea 0})      +
  ('C:\ProgramData\chocolatey\bin',
   'S:\Programs\Notepad++*','S:\Programs\Portable\Notepad++*',
   'T:\Programs\Notepad++*','T:\Programs\Portable\Notepad++*',
   'S:\Programs\Herb\util', 'T:\Programs\Herb\util',
   'D:\wintools\Tools\hm') |
   Get-ChildItem -include 'notepad++*.exe' -excl '.paf.' -file -recurse -ea 0 |
   ForEach-Object { write-warning "$(LINE) $_"; $_} |
   select -first 1).fullname
if ($NotepadPlusPlus) { new-alias np $NotepadPlusPlus -force -scope Global }
#>
Function Set-ProgramAlias {
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
    write-warning "$(LINE) $Name found: $Location [$((Get-Alias $Name -ea 0).definition)]"
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

# 'Thu, 08 Feb 2018 07:47:42 -0800 (PST)' -replace '[^\d]+$' -as [datetime] 13:47:42 -0800 (PST)'
# 'Thu, 08 Feb 2018 07:47:42 -0800 (PST)' -replace '[^\d]+$' -as [datetime] 13:47:42 -0800 (PST)'
#$raw = 'Thu, 08 Feb 2018 13:47:42 -0800 (PST)'
#$pattern = 'ddd, dd MMM yyyy Get-History:mm:ss zzz \(PST)'
#[DateTime]::ParseExact($raw, $pattern, $null)

if ($MyInvocation.HistoryID -eq 1) {
  if (Get-Command write-information -type cmdlet,Function -ea 0) {
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

get-itemproperty 'HKCU:\CONTROL PANEL\DESKTOP' -name WindowArrangementActive |
  Select-Object WindowArrangementActive | Format-List | findstr "WindowArrangementActive"
set-itemproperty 'HKCU:\CONTROL PANEL\DESKTOP' -name WindowArrangementActive -value 0 -type dword -force

# https://onedrive.live.com?invref=b8eb411511e1610e&invscr=90  Free one drive space

Function Get-CurrentIPAddress {(ipconfig) -split "`n" | Where-Object {
  $_ -match 'IPv4' } | ForEach-Object { $_ -replace '^.*\s+' }
}
Function Get-WhoAmI { "[$PID]",(whoami),(hostname) + (Get-CurrentIPAddress) -join ' ' }

If ($ShowDotNetVersions) {
  write-information ".NET dotnet versions installed"
  $DotNetKey = @('HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP',
                 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4')
  @(foreach ($key in  $DotNetKey) { Get-ChildItem $key }) | Get-ItemProperty -ea 0 |
    Select-Object @{N='Name';E={$_.pspath -replace '.*\\([^\\]+)$','$1'}},version,
      InstallPath,@{N='Path';E={($_.pspath -replace '^[^:]*::') -replace '^HKEY[^\\]*','HKLM:'}}
}

$DefaultConsoleTitle = 'Windows PowerShell'
If (Test-Administrator) {
  $DefaultConsoleTitle = 'Administrator: Windows PowerShell'
  # https://github.com/PowerShell/PowerShellGet/archive/1.6.0.zip
  try {
    if ((Get-PSVersion) -lt 6.0) {
      If (Get-Package 'Nuget' -ea 0) {
        write-warning "$(get-date -f 'HH:mm:ss') $(LINE)"
      } else {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
      }
    }
    $PSGallery = Get-PSRepository PSGallery -ea 0
    if ($PSGallery) {
      #$PSGallery
      if ($PSGallery.InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -name 'PSGallery' -InstallationPolicy 'Trusted' -ea 0
        $PSGallery = Get-PSRepository -name 'PSGallery'                  -ea 0
      }
      If ($Verbose) { $PSGallery | Format-Table }
    }
  } catch {
    Write-Information "$(LINE) Problem with PSRepository"
  }
}

$PSVersionNumber = "$($psversiontable.psversion.major).$($psversiontable.psversion.minor)" -as [double]
$CurrentWindowTitle = $Host.ui.RawUI.WindowTitle
if ($CurrentWindowTitle -match 'Windows PowerShell([\(\)\s\d]*)$') {
  $Host.ui.RawUI.WindowTitle += " $(Get-WhoAmI) OS:" +
    (Get-WMIObject win32_operatingsystem).version + "PS: $PSVersionNumber"
}

if (!(Get-Module 'Jump.Location' -listavailable -ea 0) -and $PSVersionNumber -lt 6) {
  $parms = @('-force')
  if ($PSVersionNumber -ge 5.1) { $parms += '-AllowClobber' }
  Install-Module 'Jump.Location' ### @Parms
}

If (((Get-PSVersion) -lt 6.0 ) -and (Get-Module -list Jump.Location -ea 0)) {
  Import-Module jump.location -ea 0
}

Function Update-ModuleList {
  [CmdLetBinding(SupportsShouldProcess = $true,ConfirmImpact='Medium')]
  param(
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [string[]]$name='pscx'
  )
  begin {}
  process {
    foreach ($ModuleName in $Name) {
      $InstalledModule = @(get-module $ModuleName -ea 0 -list | Sort-Object-Object -desc Version)
      $version = if ($InstalledModule) {
        $InstalledModule | ForEach-Object {
          write-warning "$(LINE) Installed module: $($_.Version) $($_.Name)"
        }
        $InstalledModule = $InstalledModule[0]
        $InstalledModule.version
      } else {
        write-warning "Module $ModuleName not found, searching gallery..."
        '0.0'  # set ZERO VERSION
      }
      $FoundModule = find-module $ModuleName -minimum $version -ea 0 |
                     Sort-Object-Object version -desc  | Select-Object -Object -first 1
      If ($FoundModule) {
        Write-Warning "$($FoundModule.Version) $($FoundModule.Name)"
        If ($InstalledModule) {
          If ($FoundModule.version -gt $InstalledModule.version) {
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

write-warning "$(get-date -f 'HH:mm:ss') $(LINE) Before Show-Module "

if ($ShowModules) {
 get-module -list | Where-Object {$_.name -match 'PowerShellGet|PSReadline' -or $_.author -notmatch 'Microsoft' } |
   Format-Table version,name,author,path
} else {}
write-warning "$(get-date -f 'HH:mm:ss') $(LINE) After Show-Module "

# Get .Net Constructor parameters
# ([type]"Net.Sockets.TCPClient").GetConstructors() | ForEach-Object { $_.GetParameters() } | Select-Object Name,ParameterType
Function Get-Constructor {
  param([Alias('Name')][string[]]$TypeName)
  ForEach ($Name in $TypeName) {
    ([type]$Name).GetConstructors() | ForEach-Object {
      write-host "$_"; $_.GetParameters()
    } | Select-Object -Object Name, ParameterType
  }
}

write-information "Useful modules: https://blogs.technet.microsoft.com/pstips/2014/05/26/useful-powershell-modules/"
$PSCXprofile = 'C:\Users\hmartin\Documents\WindowsPowerShell\Pscx.UserPreferences'
write-information "import-module -noclobber PSCX $PSCXprofile"
if ($psversiontable.psversion.major -lt 6) {
  write-information "import-module -noclobber PowerShellCookbook"
}

<#
[System.Windows.Forms.Screen]::AllScreens
[System.Windows.Forms.Screen]::PrimaryScreen
# Make nicely formatted simple directory for notes:
Get-ChildItem | Sort-Object LastWriteTime -desc | ForEach-Object { '{0,23} {1,11} {2}' -f $_.lastwritetime,$_.length,$_.name }
#>

<#
ts.ecs-support.com:32793  terminal server 10.10.11.80
ts.ecs-support.com:32795 FS02
#>
# Get-WindowsFeature 'RSAT-DNS-Server'
# Import-Module ServerManager

if (Join-Path $PSProfileDirectory "$($env:UserName).ps1" -ea 0 -ev $Null) {

}
# (Get-IPAddress).ipaddresstostring -match '^10.10'
$ecs       = 'ts.ecs-support.com'
# $ecsts01 = 'ts.ecs-support.com'
# $ecsts02 = 'ts.ecs-support.com'
$j1        = "$($ecs):32793"
$j2        = "$($ecs):32795"
$ts1       = "ecs-DCts01"
$ts2       = "ecs-DCts02"

# Join-Path 'C:\Util','c:\Program*\*','C:\ProgramData\chocolatey\bin\','T:\Programs\Tools\Util','T:\Programs\Util','S:\Programs\Tools\Util','S:\Programs\Util' 'NotePad++.exe' -resolve -ea 0
# PsExec64.exe -h \\REMOTECOMPUTER qwinsta | find "Active"
# runas /noprofile /netonly /user:"DOMAIN\USERNAME" "mstsc /v:REMOTECOMPUTER /shadow:14 /control"

Function New-RDPSession {
  [CmdLetBinding()]param(
    [Alias('Remote','Target','Server')]$ComputerName,
    [Alias('ConnectionFile','File','ProfileFile')]$path='c:\bat\good.rdp',
    [int]$Width=1350, [int]$Height:730,
    [Alias('NoConnectionFile','NoFile','NoPath')][switch]$NoProfileFile,
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$RemArgs,
    [Alias('Assist')][switch]$Control,
    [Alias('Watch')]$Shadow
  )
  If (!(Test-Path $Path)) { $NoProfileFile = $False }
  $argX = $args
  # $argX += '/prompt'
  If (!$NoProfileFile -and (!(Test-Path $Path))) {
    Write-Warning 'RDP Profile not found: $Path'
    $NoProfile = $True
  }
  if ($NoProfileFile) { mstsc /v:$ComputerName /w:$Width /Get-History:$Height @argX }
  else                { mstsc /v:$ComputerName $Path @argX }
} New-Alias RDP New-RDPSession -force

if ($AdminEnabled -and (get-command 'ScreenSaver.ps1' -ea 0)) { ScreenSaver.ps1 }

<# Testing ideas #>

Function Merge-Object {
  Param (
    [Parameter(mandatory=$true)]$Object1,
    [Parameter(mandatory=$true)]$Object2
  )
  foreach ($Prop in ($Object2 | gm -membertype *property)) {
    $Object1 |
      Add-Member -MemberType NoteProperty -Name $Prop.name -Value $Object2.$($Prop.name) -ea 0
  }
  $Object1
}

Function Get-ServiceProcess {      # ToDo add params for ID,Name to find
  $Processes = Get-Process
  $Services  = Get-WMIObject Win32_Service
  $Services | ForEach-Object {
    $Service = $_;
    $Processes                               |
      Where-Object ID -eq $Service.ProcessID |
      Select -First 1                        |
      ForEach-Object { Merge-Object $_ $Service }
  } | Select-Object ID,State, Status,Name,Path
}

Function Get-HelpLink {
  $args
  "Args: $($args.count) $($args.gettype())"
  $a = $args
  (((help @a -full) -join ' ## ') -split '(\s+##\s+){2,}' | Select-Object -String '.*http.*' -all |
    Select-Object -expand matches).value -replace ' ## ',"`n" | ForEach-Object {"$_`n"} | Format-List
}; New-Alias ghl Get-HelpLink -force

Function Get-HelpLink {
  $a = $args
  #$outputEncoding=[System.Console]::OutputEncoding
  (((help @a -full) -join ' ## ') -split '(\s+##\s+){2,}' | Select-Object -String '.*http.*' -all |
    Select-Object -expand matches).value -replace ' ## ',"`n" | ForEach-Object {"$_`n"} | Format-List
}
; New-Alias ghl Get-HelpLink -force
# get-help about_* -full | ForEach-Object { '{0,-38}{1,6}  {2}' -f $_.Name,$_.Length,$_.Synopsis }

if (Test-Path "$Home\Documents\WindowsPowerShell\tt.xml") {
	if ($hc = import-clixml -first 1 "$Home\Documents\WindowsPowerShell\tt.xml" -ea 0) {
		$hc | ForEach-Object {$_.commandline = @'
		"This is a test4"
		Function F4 { "Function Test4"}
		$testclip = "Clip test4"
'@
		}

		$hc = import-clixml -first 1 "$Home\Documents\WindowsPowerShell\tt.xml"
		#$hid = ($hc | ForEach-Object {$_.commandline = gcb } | add-history -passthru).id; ihy $hid
	}
}

### gcb | ForEach-Object { $a = $_ -split '\.'; [array]::reverse($a); $a -join '.'}

#C:\Windows\Microsoft.NET\Framework64\v4.0.30319\config\machine.config
if ($psversiontable.psversion.major -lt 6) {
  [System.Runtime.InteropServices.RuntimeEnvironment]::SystemConfigurationFile
}


#> # End testing ideas


Function Set-DefaultPropertySet { param([Object]$Object,
  [Alias('Properties','Property','Members')][string[]]$DefaultProperties)
  If (!$Object) { return $Null }
  $defaultDisplayPropertySet =
    New-Object System.Management.Automation.PSPropertySet(
      'DefaultDisplayPropertySet',[string[]]$defaultProperties)
  $PSStandardMembers =
    [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
  $OBject | Add-Member MemberSet PSStandardMembers $PSStandardMembers -PassThru
}

Function Get-WinStaSession {
  [CmdletBinding()]param($UserName, [Alias('Me','My','Mine')][switch]$Current)
  $WinSta = qwinsta | Select-Object -skip 1
  write-verbose "Winsta count: $($WinSta.count)"
  $WinSta | ForEach-Object {
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
    if ($Current)    { $Session = $Session | Where-Object Current  -eq    $True     }
    if ($SelectUser) { $Session = $Session | Where-Object UserName -match $UserName }
    if ($Session) { Set-DefaultPropertySet $Session @('Current','UserName','ID','State')}
  }
}
New-Alias ws  Get-WinStaSession -force -scope Global
New-Alias gws Get-WinStaSession -force -scope Global
function Get-CommandPath {
  [CmdletBinding()]param(
    [Alias('Clean')][switch]$Unique,
    [Alias('Test')][switch]$Resolve
  )
  $paths = $Env:path -split ';' | Select -Unique:$Unique
  If ($Resolve) {
    Resolve-Path $Paths
  } else { $Paths }
}
#################################################################

$InformationPreference = 'continue'
write-information "$(LINE) InformationPreference: $InformationPreference"
write-information "$(LINE) Test hex format: $("{0:X}" -f -2068774911)"
# "{0:X}" -f -2068774911

Function Get-DriveTypeName ($type) {
	$typename = @('UNKNOWN',     # 0 # The drive type cannot be determined.
					  		'NOROOTDIR',   # 1 # The root path is invalid; for example, there is no volume mounted at the specified path.
								'REMOVABLE',   # 2 # The drive has removable media; for example, a floppy drive, thumb drive, or flash card reader.
								'FIXED',       # 3 # The drive has fixed media; for example, a hard disk drive or flash drive.
								'REMOTE',      # 4 # The drive is a remote (network) drive.
								'CDROM',       # 5 # The drive is a Set-Location-ROM drive.
								'RAMDISK')     # 6 # The drive is a RAM disk.
  if (($type -le 0) -or ($type -ge $typename.count)) {return 'INVALID'}
  $typename[$type]
}
Function Get-Volume {
 (Get-WMIObject win32_volume ) | Where-Object {$_.DriveLetter -match '[A-Z]:'} |
  ForEach-Object { "{0:2} {0:2} {0:9} {S:9} "-f $_.DriveLetter, $_.DriveType, (Get-DriveTypeName $_.DriveType), $_.Label, ($_.Freespace / 1GB)}
  # % {"$($_.DriveLetter) $($_.DriveType) $(Get-DriveTypeName $_.DriveType) $($_.Label) $($_.Freespace / 1GB)GB"}
}

Function Get-WMIClassInfo {
  [CmdletBinding()] param([string]$className, [switch]$WrapList)
  #https://www.darkoperator.com/blog/2013/2/6/introduction-to-wmi-basics-with-powershell-part-2-exploring.html
  $r = (Get-WmiObject -list $className -Amended).qualifiers | Select-Object -Object name, value
  if ($WrapList) { $r | Format-Table -AutoSize -Wrap } else { $r }
}

# [AppDomain]::CurrentDomain.GetAssemblies() | sort FullName | Select FullName

  # Fixed Get-DotNetAssembly
Function Get-DotNetAssembly  {
  [CmdletBinding()]param(
    [string[]]$Include=@('.*'),
    [string[]]$Exclude=@('^$'),
    [switch]$fullname)
  $Inc = '(' + ($Include -join ')|(') + ')'
  $Exc = '(' + ($Exclude -join ')|(') + ')'
  write-verbose "Include: $Inc"
  write-verbose "Exclude: $Exc"
  write-verbose "Full: $([boolean]$full)"
  [appdomain]::CurrentDomain.GetAssemblies() | Where-Object {
    $_.fullname -match $inc -and $_.fullname -notmatch $Exc
    #-and ($_.IsDynamic -or ($_.GetExportedTypes()))
  }# | ForEach-Object {
   # if ($fullname) {
   #   $_ | Select-Object FullName
   # } else {
   #   $_ | Select-Object GlobalAssemblyCache,IsDynamic,ImageRuntimeversion,Fullname,Location
   # }
   #}
}
new-alias gdna Get-DotNetAssembly -force

Function Get-TypeX {
  [CmdletBinding()]param(
    [string[]]$Include=@('.*'),
    [string[]]$Exclude=@('^$')
  )
  Get-DotNetAssembly -include $Include -exclude $Exclude | ForEach-Object {
    $Asm = $_
    switch -wildcard ($Asm.FullName) {
      'Anonymously Hosted DynamicMethods Assembly*'                        { break }
      'Microsoft.PowerShell.Cmdletization.GeneratedTypes*'                 { break }
      'Microsoft.Management.Infrastructure.UserFilteredExceptionHandling*' { break }
      'Microsoft.GeneratedCode*'                                           { break }
      'MetadataViewProxies*'                                               { break }
      default {
        try {
          Write-Verbose "Asm: $($Asm.FullName)"
          $Asm.GetExportedTypes() | Where-Object {
            write-verbose "$_"
            Select-Object @{N='Assembly';E={($_.Assembly -split '.')[0]}},
              IsPublic, IsSerial, FullName, BaseType
          }
        } catch {
          write-warning "Not Supported: $($Asm.FullName)"
        }
      }
    }
  }
}

  #$Op    = 'match';
  #$NegOp = "not$Op"
  #Invoke-Expression "Function ObjectFilter {
  #  If ($_ $Op $Include -and $_ -$NegOp $Exclude) { $_ }
  #}"

[PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Add('accelerators', [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators'))
Function Get-Accelerator {
  param($Include='.', $Exclude='^$', [switch]$Like)
  $Acc = [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::get
  ForEach ($key in $Acc.Keys) {
    if ($key -notmatch $Include -or $key -match $Exclude) {continue}
    [pscustomobject]@{
      Accelerator = $key
      Definition  = $Acc.$key
    }
  }
}

Function Get-HistoryCommandline {
  [CmdLetBinding()]param(
    #[Int64[]]$ID,
    #[Int32]$Count,
    #[Switch]$ShowID
  )
  (get-history @args).commandline
} New-Alias cl  Get-HistoryCommandline -force
  new-alias gch Get-HistoryCommandLine -force
  new-alias ghc Get-HistoryCommandLine -force
  new-alias gcl Get-HistoryCommandLine -force
  new-alias hcm Get-HistoryCommandLine -force

Function Select-History {
  [CmdLetBinding()]param(
    [string]$Pattern,
    [int]$Count=9999,
    [Alias('ID','Object','FullObject')][switch]$HistoryInfo,
    [Alias('JustCommandLine','Bare','String','CLine')][switch]$CommandLine,
    $Exclude='Select-History|(\bsh\b)'
  )
  begin {
    $LastID  = (Get-History -count 1).ID
    $IDWidth = "$LastID".length
    write-verbose "Last ID: $LastID Width: $IDWidth"
    $FoundCount = 0
    $FirstTime = $LastTime = $FirstID = $LastId = ''
    $IDFormat = if ($CommandLine) { '' } else { "{0,$IDWidth} " }
  }
  process {
    Get-History | Where-Object {
        $_.commandline -match $Pattern -and $_.CommandLine -notmatch $Exclude } |
        Select-Object -last $Count | ForEach-Object {
      If (!$FirstID) { $FirstID = $_.ID; $FirstTime = $_.StartExecutionTime }
      if ($HistoryInfo) {
        $_                      # Output the entire history object
      } else {
        $id = $IDFormat -f $_.id
        "$id$($_.CommandLine)"
      }
      #if ($Verbose) {
        $LastID = $_.ID
        $LastTime = $_.EndExecutionTime
        $FoundCount++
      #}
    }
  }
  end {
    write-verbose "FirstID: $FirstID FirstTime: $FirstTime LastID: $LastID LastTime: $LastTime"
  }
}
new-alias sh Select-History -force -scope Global

Function Get-RunTime {
  param(
    [Parameter(ValueFromPipeline=$True)]
    [Microsoft.PowerShell.Commands.HistoryInfo[]]$historyitem,
    $Count = 1,
    [switch]$Duration,
    [switch]$Format
  )
  begin {
    If ($HistoryItem.Count -gt $Count) {
      $HistoryItem = $HistoryItem | Select -Last $Count
    }
    If (!$HistoryItem) { $HistoryItem = Get-History -Count $Count }
    $width = +1 * "$((($HistoryItem | Measure-Object -max id).maximum))".length
    $F1 = '{0,5:N2}';
    $F2 = "ID# {1,$($Width):D}: "
    $F2 = "{1,$($Width):D} "
    write-verbose "$(LINE) width $Width $F2"
  }
  process {
    foreach ($hi in $HistoryItem) {
      $CL = $hi.commandline
      $ID = $hi.id
      $RunTime = $hi.endexecutiontime - $hi.startexecutiontime
      If ($Format) {
        switch ($RunTime) {
          {$Full                } { $_                                           ; break }
          {$_.Days         -gt 0} {"$F2 $F1 Days  {2}" -f $_.TotalDays   ,$ID,$CL; break }
          {$_.Hours        -gt 0} {"$F2 $F1 Hours {2}" -f $_.TotalHours  ,$ID,$CL; break }
          {$_.Minutes      -gt 0} {"$F2 $F1 Mins  {2}" -f $_.TotalMinutes,$ID,$CL; break }
          {$_.Seconds      -gt 0} {"$F2 $F1 Secs  {2}" -f $_.TotalSeconds,$ID,$CL; break }
          {$_.Milliseconds -gt 0} {"$F2 $F1 ms    {2}" -f $_.TotalSeconds,$ID,$CL; break }
        }
      } else {
        [PSCustomObject]@{
          Id          = $hi.Id
          RunTime     = If ($Duration) { $RunTime } else { $RunTime.TotalSeconds }
          CommandLine = $hi.CommandLine
        }
      }
    }
  }
}; New-Alias rt Get-RunTime -force -scope Global

Function get-syntax   {
  param(
  )
  $Result = get-command -syntax @args
  write-warning "result: $Result"
  Foreach ($R in $Result) {
    If ($R -and $R -match '^(["'']?.+["'']?(?!= ))|(\S+)$' -and $R -notmatch '^[\[\-]<') {
      "Get-Command $R -synax -ea 0"
      Get-Command $R -syntax -ea 0
    } else { $Result }
  }
}; new-alias syn get-syntax -force
Function syn { get-command @args -syntax }
Function get-fullhelp { get-help -full @args }
'hf','full','fh','fhelp','helpf' | ForEach-Object { new-alias $_ get-fullhelp -force -ea continue }

write-information "$(LINE) $home"
write-information "$(LINE) Try: import-module -prefix cx Pscx"
write-information "$(LINE) Try: import-module -prefix cb PowerShellCookbook"

new-alias npdf 'C:\Program Files (x86)\Nitro\Reader 3\NitroPDFReader.exe' -force -scope Global

Function esf {
  $parms  = @('-dm')
  $target = @()
  $name   = '-full-path-and-name'
  $type   = @('-regex')
  ForEach ($arg in $args) {
    Switch -regex ($arg) {
      '^-regex'    {                  break }
      '^-...name$' { $name = $arg;    break }
      '^-'         { $parms  += $arg; break }
      default      { $target += $arg        }
    }
  }
  $target = "$($target -join '.*')"
  $args = $parms + $type + $name
  write-verbose "es $target $($args -join ' ')"
  write-verbose "$(& 'C:\Program Files\WindowsPowerShell\Modules\Pscx\3.2.1.0\Apps\EchoArgs.exe' $target @args)"
  es $target @args | ForEach-Object {
    if ($_ -match '^(\d\d/\d\d/\d{4})\s+') {
      $_ -replace '^(\d\d/\d\d/\d{4})\s+', "$(Get-Date $Matches[1] -format 'yyyy-MM-dd') "
    } else { $_ }
  }
}

<#  $foreach loop variable iterator WEIRD remove this junk
foreach ($a in ('a','b','c','d','e')) { $a; [void]$foreach.movenext(); $foreach.gettype() }
[]
[SZArrayEnumerator] |gm
foreach ($a in ('a','b','c','d','e')) { $a; [void]$foreach.movenext(); $foreach.gettype() | gm }
foreach ($a in ('a','b','c','d','e')) { $a; [void]$foreach.movenext(); $foreach }
foreach ($a in ('a','b','c','d','e')) { $foreach }
foreach ($a in ('a','b','c','d','e')) { "$a $foreach" }
foreach ($a in ('a','b','c','d','e')) { "$a $foreach"; $x++ }
foreach ($a in ('a','b','c','d','e')) { $x++; "$a $foreach";  }
$x
$x; foreach ($a in ('a','b','c','d','e')) { $x++; "$a $foreach";  }
$x; foreach ($a in ('a','b','c','d','e')) { $x++; "$a $foreach";  }
$x
$x=0; foreach ($a in ('a','b','c','d','e')) { $x++; "$a $foreach";  }
$x
$x=0; foreach ($a in ('a','b','c','d','e')) { ++$x; "$a $foreach";  }
$x
$x=0; foreach ($a in ('a','b','c','d','e')) { $x; $x++; "$a $foreach";  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $x; $x++; "$a $foreach"; $x+++  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $x; $x++; "$a $foreach"; $x++ }

foreach ($a in ('a','b','c','d','e')) { $a; [void]$foreach.movenext(); $foreach.gettype() | gm }
foreach ($a in ('a','b','c','d','e')) { $a; [void]$foreach.movenext(); $foreach }
foreach ($a in ('a','b','c','d','e')) { $foreach }
foreach ($a in ('a','b','c','d','e')) { "$a $foreach" }
foreach ($a in ('a','b','c','d','e')) { "$a $foreach"; $x++ }
foreach ($a in ('a','b','c','d','e')) { $x++; "$a $foreach";  }
$x
$x; foreach ($a in ('a','b','c','d','e')) { $x++; "$a $foreach";  }
$x; foreach ($a in ('a','b','c','d','e')) { $x++; "$a $foreach";  }
$x
$x=0; foreach ($a in ('a','b','c','d','e')) { $x++; "$a $foreach";  }
$x
$x=0; foreach ($a in ('a','b','c','d','e')) { ++$x; "$a $foreach";  }
$x
$x=0; foreach ($a in ('a','b','c','d','e')) { $x; $x++; "$a $foreach";  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $x; $x++; "$a $foreach"; $x+++  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $x; $x++; "$a $foreach"; $x++ }
h -count 20
$x=0; foreach ($a in ('a','b','c','d','e')) { $foreach }
$x=0; foreach ($a in ('a','b','c','d','e')) { $foreach.Current }
$array = @(1,2,3)
$array.GetEnumerator() |gm
$array.GetEnumerator().gettype()
$x=0; foreach ($a in ('a','b','c','d','e')) {[int]$foreach }
$x=0; foreach ($a in ('a','b','c','d','e')) {$foreach.gettype() }
$x=0; foreach ($a in ('a','b','c','d','e')) {$foreach.ToString() }
$x=0; foreach ($a in ('a','b','c','d','e')) {$foreach.ToInt() }
$x=0; foreach ($a in ('a','b','c','d','e')) {$foreach.ToInteger() }
$x=0; foreach ($a in ('a','b','c','d','e')) {$foreach.ToInt32() }
$x=0; foreach ($a in ('a','b','c','d','e')) {$foreach = get-member -static }
$x=0; foreach ($a in ('a','b','c','d','e')) {$foreach = get-member  }
$x=0; foreach ($a in ('a','b','c','d','e')) { [object]$foreach = gm  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $foreach.current  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $foreach.tostring()  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $foreach.getindex()  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $foreach.count  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $foreach.currentindex  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $foreach.index  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $foreach.position  }
$x=0; foreach ($a in ('a','b','c','d','e')) { $foreach.upperbound  }

#>

Function ahk {
  if ($args[0]) { C:\util\AutoHotKey\autohotkey.exe @args               }
  else          { C:\util\AutoHotKey\autohotkey.exe /r "c:\bat\ahk.ahk" }
};

Function ahk {
  [CmdletBinding()]param([string[]]$Path=@('c:\bat\ahk.ahk'))
  $argx = $args
  write-verbose "Path [$($Path -join '] [')] Argc $($argx.count): [$($args -join '], [')]"
  #if (!$argx.count) { $argx = [string[]]@('/r') }
  [string[]]$a = if ($argx.count) { $argx } else { @('/r') }
  write-verbose "ArgC: $($argx.count) [$($argx -join '], [')]"
  $path | ForEach-Object { C:\util\AutoHotKey\AutoHotkey.exe $_ @a }
}
Remove-Item Alias:a -force -ea 0 2>$Null
New-Alias a ahk -force -scope Global

Function d    { cmd /c dir @args}
Function df   { Get-ChildItem @args -force -file       }
Function da   { Get-ChildItem @args -force             }
Function dfs  { Get-ChildItem @args -force -file -rec  }
Function dd   { Get-ChildItem @args -force -Get-ChildItem       }
Function dds  { Get-ChildItem @args -force -Get-ChildItem  -rec }
Function ddb  { Get-ChildItem @args -force -Get-ChildItem       | ForEach-Object { "$($_.FullName)" } }
Function db   { Get-ChildItem @args -force             | ForEach-Object { "$($_.FullName)" }}
Function dsb  { Get-ChildItem @args -force       -rec  | ForEach-Object { "$($_.FullName)" }}
Function dfsb { Get-ChildItem @args -force -file -rec  | ForEach-Object { "$($_.FullName)" }}
Function dod  { dd  @args -force | Sort-Object lastwritetime }
Function dfod { df  @args -force | Sort-Object lastwritetime }
Function ddod { dd  @args -force | Sort-Object lastwritetime }
Function dfp  { d /a-@args d /b  | ForEach-Object {Get-ChildItem "$_"} }
Function dl   { Get-ChildItem @args -force -attr ReparsePoint }
new-alias dj dl -force -scope Global
new-alias w  where.exe -force
new-alias wh where.exe -force
new-alias wi where.exe -force
Function od {
  param(
    [parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,
    ParameterSetName='Path')][Alias('pspath','fullname','filename')][object[]]$Path=@()
  )
  begin { $a=@(); $parent = ''}
  process {
    if ($parent -ne $path.psparent) {
      $a | Sort-Object @args lastwritetime,starttime
      $a = @()
    }
    $a += $path;
    $parent = $path.psparent;
  }
  end { $a | Sort-Object @args lastwritetime,starttime }
}
Function os {
  param(
    [parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,
    ParameterSetName='Path')][Alias('pspath','fullname','filename')][object[]]$Path=@()
  )
  begin { $a=@(); $parent = ''}
  process {
    if ($parent -ne $path.psparent) {
      $a | Sort-Object-object length @args
      $a = @()
    }
    $a += $path;
    $parent = $path.psparent;
  }
  end { $a | Sort-Object-object length @args }
}
Function cpy {cmd /c copy @args}
Function mov {cmd /c move @args}
Function fr  {cmd /c for @args}
Function frf {cmd /c for /f @args}
Function ff  {cmd /c for /f @args}
Function Get-Drive {
  [CmdletBinding()] param(
    [string[]]$name='*',
	  [string]  $scope=0,
	  [string]  $PSProvider='FileSystem')
  get-psdrive -name $name -psprovider $psprovider -scope $scope
}


# https://poshtools.com/2018/02/17/building-real-time-web-apps-powershell-universal-dashboard/
# https://docs.microsoft.com/en-us/dotnet/api/?view=netframework-4.5
# Function invoke-clipboard {$script = ((Get-Clipboard) -join "`n") -replace '(Function\s+)', '$1 '; . ([scriptblock]::Create($script))}
#### Because of DIFFICULTY with SCOPE
# $PSProfileDirectory = Split-Path $PSProfile
$ICFile = "$PSProfileDirectory\ic.ps1"
write-information "$(LINE) Create ic file: $ICFile"
set-content  $ICFile '. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))'
set-alias ic $ICFile -force -scope global -option AllScope
# get-uptime;Get-WURebootStatus;Is-RebootPending?;Get-Uptime;PSCx\get-uptime;boottime.cmd;uptime.cmd
#
Function Get-BootTime { (Get-CimInstance win32_operatingsystem).lastbootuptime }
write-information "$(LINE) Boot Time: $(Get-date ((Get-CimInstance win32_operatingsystem).lastbootuptime) -f 's')"
Function ql {  $args  }
Function qs { "$args" }
Function qa {
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
Function qa {
  [CmdLetBinding(PositionalBinding=$False)]
  param(
    [Parameter()]$OFS=$(Get-Variable OFS -scope 1 -ea 0 -value),
    [Parameter()]        $Quotes="'",
    [Parameter()][switch]$DoubleQuotes,
    [Parameter()][switch]$SingleQuotes,
    [Parameter()][switch]$NoQuotes,
    [parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]$Args
  )
  $q = Switch ($True) {
    { $DoubleQuotes }  { '"'; break }
    { $SingleQuotes }  { "'"; break }
    { $NoQuotes     }  { "'"; break }
    Default { $Quotes }
  }
  $args | ForEach-Object { "$q$_$q" }
}

# $ic = [scriptblock]::Create('(Get-Clipboard) -join "`n"')
# $ic = '. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))'
# $ic = [scriptblock]::Create('. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))')

# https://weblogs.asp.net/jongalloway/working-around-a-powershell-call-depth-disaster-with-trampolines

write-information "$(LINE) set Prompt Function"
try {
  if (!$global:PromptStack) {
    #if ($global:PromptStack) -ne )
    [string[]]$global:PromptStack +=   (Get-Command prompt).ScriptBlock
	}
} catch {
	[string[]]$global:PromptStack  = @((Get-Command prompt).ScriptBlock)
}

write-information "$(LINE) Pushed previous prompt onto `$PromptStack: $($PromptStack.count) entries"
write-information "$(LINE) prompt='PS $($executionContext.SessionState.Path.CurrentLocation) $('>' * $nestedPromptLevel + '>')'"
#Function Global:prompt { "PS '$($executionContext.SessionState.Path.CurrentLocation)' $('>.' * $nestedPromptLevel + '>') "}

Function Global:prompt {
  If (!(Get-Variable MaxPrompt -ea 0 2>$Null)) { $MaxPrompt = 45 }
  $loc = "$($executionContext.SessionState.Path.CurrentLocation)"
  $Sig = " |>$('>' * $nestedPromptLevel)"
  if ($Global:MaxPromptLength) {
    $LocLen = $Loc.length; $SigLen = $Sig.Length
    $Length = $LocLen + $SigLen
    $Excess = $Length - $Global:MaxPromptLength
    If ($Excess -gt 0) {
      $Excess = [Math]::Min($Excess, $LocLen)
    }
  }
  write-host -nonewline "'$Loc'$Sig" -fore Cyan -back DarkGray
  ' '   # Make normal background SPACE and give PS something to show
}

<#
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-6

function prompt {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity

  $(if (test-path variable:/PSDebugContext) { '[DBG]: ' }
    elseif($principal.IsInRole([Security.Principal.WindowsBuiltInRole]
      "Administrator")) { "[ADMIN]: " }
    else { '' }
  ) + 'PS ' + $(Get-Location) +
    $(if ($nestedpromptlevel -ge 1) { '>>' }) + '> '
}

function prompt {   # displays the history ID of the next command
   # The at sign creates an array in case only one history item exists.
   $history = @(get-history)
   if($history.Count -gt 0)
   {
      $lastItem = $history[$history.Count - 1]
      $lastId = $lastItem.Id
   }

   $nextCommand = $lastId + 1
   $currentDirectory = get-location
   "PS: $nextCommand $currentDirectory >"
}
# Debuggers https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_debuggers?view=powershell-6

#>
new-alias v 'C:\Program Files (x86)\VLC\vlc.exe' -force -scope Global
;;
Function Global:prompt {
  If (!((Test-Path Function:\MaxPromptLength) -and
        (Get-Variable MaxPromptLength -ea 0 2>$Null))) {
    $MaxPromptLength = 45
  }
  $Location = "$($executionContext.SessionState.Path.CurrentLocation)"
  $Sigil  = ">$('>' * $nestedPromptLevel)" -replace '>$', '#>'
  $Prompt = "$Location $Sigil"
  $Length = $Prompt.Length
  If ($False -and ($Length + 5) -gt $MaxPromptLength) {
    $Excess = $Length - $MaxPromptLength
    $Prompt = $Prompt.SubString(0,2) + $Prompt.SubString($Excess+5, $MaxPromptLength+5)
  }
  $Prompt = "<# $Prompt"
  write-host -nonewline $Prompt -fore Cyan -back DarkGray
  ' '   # Make normal background SPACE and give PS something to show
}

Function Format-Error {
  [CmdletBinding()]Param(
    [parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
      [Alias('Error')][ErrorRecord[]]$ErrorList
  )
  Begin {}
  process {
    $ErrorList | Foreach-Object {
      $Line = $_.invocationinfo.ScriptLineNumber
      $Char = $_.invocationinfo.OffSetInLine
      $Name = If ($_.invocationinfo.PSCommandPath) {
        Split-Path -ea 0 $_.invocationinfo.PSCommandPath -Leaf
      }
      $Msg  = "[$($_.tostring())]"
      $FQID = $_.FullyQualifiedErrorId -replace ',.*'
      $Cmd1 = $_.invocationinfo.InvocationName
      $Cmd2 = $_.invocationinfo.MyCommand.Name
      If ($Cmd1 -ne $Cmd2) { $Cmd1 += "/$Cmd2" }
      ( "LINE: $Line","CHAR:$Char",$FQID,$Cmd1,$Name,$Msg |
        Where-Object { $_ }
      ) -join ' '
    }
    write-verbose ('-' * 72)
  }
  End {}
}

Function Show-ConsoleColor {
  param ([int]$MaxLength = 6, [int]$SkipLines = 0, [switch]$Bracket)
  $ConsoleWidth = $host.ui.rawui.WindowSize.Width
  $MaxWidth     = ($ConsoleWidth - 2) / 17
  $MaxLength    = [Math]::Max($MaxLength, $MaxWidth)
  $SkipLines    = [Math]::Min(0,$SkipLines)
  $NewLines     = "`n" * $SkipLines
  $ColorValues  = [consolecolor]::GetValues('consolecolor')
  $ColorNames   = $ColorValues -replace 'Dark','D'
  $LineWidth    = 17 * ($MaxLength) + 2
  $BlankLine    = If ($Bracket) { ' ' * $LineWidth } else { '' }
  $ColorValues | ForEach-Object {
    $Back = $_
    $BackName = " $($_ -replace 'Dark','D') ".PadRight($MaxLength).SubString(0,$MaxLength)
    If ($Bracket) { Write-Host "$BlankLine$NewLines" -back $Back }
    Write-Host "$($BackName)" -nonewline -fore White -back Black
    $ColorValues | ForEach-Object {
      $Name = " $($_ -replace 'Dark','D') ".PadRight($MaxLength).SubString(0,$MaxLength)
      Write-Host $name -nonewline -fore $_ -back $Back
    }
    if ($Bracket) { Write-Host "$BlankLine$NewLines" -back $Back }
    else          { Write-Host "$NewLines" }
  }
}

# Function docs {
#   [CmdletBinding()]param (
#     [Parameter(Position='0')][string]$path="$Home\Documents",
#     [Parameter(Position='1')][string]$subdirectory,
#     [switch]$pushd
#   )
#   try {
#     write-verbose $Path
#     if (Test-Path $path) {
#       if ($pushd) { pushd $path } else { Set-Location $path }
#       if ($subdirectory) {Set-Location $subdirectory}
#     }	else {
#       throw "Directory [$Path] not found."
#     }
#   }	catch {
#     write-error $_
#   }
# }

# Function books {
#   if (Test-Path "$($env:userprofile)\downloads\books") {
#     Set-Location "$($env:userprofile)\downloads\books"
# 	} elseif (Test-Path "C:\books") {
#     Set-Location "C:\books"
# 	}
# 	if ($args[0]) {Set-Location $args[0]}
# }

$ECSTraining = "\Training"
$SearchPath  = 'C:\',"$Home\Downloads","T:$ECSTraining","S:$ECSTraining"
ForEach ($Path in $SearchPath) {
  try {
    if (Test-Path (Join-Path $Path 'Books' -ea 0) -ea 0) {
      $Books = Resolve-Path (Join-Path $Path 'Books' -ea 0) -ea 0
      If ($Books) { break }
    }
  } catch {}  # just ignore
  $Books = $PSProfile
}
$SearchPath  = 'C:\',"S:$ECSTraining","T:$ECSTraining","$Home\Downloads"
ForEach ($Path in $SearchPath) {
  try {
    if (Test-Path (Join-Path $Path 'Dev' -ea 0) -ea 0) {
      $Dev = Resolve-Path (Join-Path $Path 'Dev' -ea 0) -ea 0
      If ($Dev) { break }
    }
  } catch {}  # just ignore
  $Dev = $PSProfile
}

Function Test-Clipboard { Get-Clipboard | Test-Script };
New-Alias tcb  Test-ClipBoard -force -scope Global
New-Alias gcbt Test-ClipBoard -force -scope Global
Function Get-HistoryCount {param([int]$Count) get-history -count $Count }
New-alias count Get-HistoryCount -force -scope Global
write-warning "$(get-date -f 'HH:mm:ss') $(LINE) Before Go"
$goHash = [ordered]@{
  docs       = "$home\documents"
  down       = "$home\downloads"
  download   = "$home\downloads"
  downloads  = "$home\downloads"
  book       = $books
  books      = $books
  psbook     = "$books\PowerShell"
  psbooks    = "$books\PowerShell"
  psh        = "$books\PowerShell"
  pshell     = "$books\PowerShell"
  power      = "$books\PowerShell"
  pro        = $PSProfileDirectory
  prof       = $PSProfileDirectory
  profile    = $PSProfileDirectory
  txt        = 'c:\txt'
  text       = 'c:\txt'
  esb        = 'c:\esb'
  dev        = 'c:\dev'
}

Function Set-GoAlias {
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

Function Set-GoLocation {
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
           new-alias jpushd Set-JumpLocation -force -scope Global
  } else { new-alias jpushd pushd            -force -scope Global }
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
    :OuterForEach ForEach ($p in ($Target)) {    #  | ForEach-Object {$_ -split ';'}  ### @($path.foreach{$_.split(';')})
      if ($goHash.Contains($p) -and (Test-Path $goHash.$p)) { $p = $goHash.$p}
      write-verbose "$(LINE) Foreach P: $p"
      if (Test-Path $p -ea 0) {
        $ValidPath += Resolve-Path $p -ea 0
        ForEach ($Sub in ($subdir)) {   #  | ForEach-Object {$_ -split ';'}
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
      if ($true -or $pushd) { jpushd       $ValidPath    }
      else                  { Set-Location $ValidPath[0] }
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

Function Set-GoLocation {
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
  if (Get-Command set-jumplocation -module Jump.Location -ea 0) {
           new-alias jpushd Set-JumpLocation -force -scope Global
  } else { new-alias jpushd pushd            -force -scope Global }
  if (!(get-variable gohash -ea 0)) { $goHash = @{} }
  write-verbose "$(LINE) Path: $Path InvocationName: $InvocationName"
  $Target = @(if ($goHash.Contains($InvocationName)) {
    $goHash.$InvocationName -split ';' |  Where-Object { Test-Path $_ }
  })
  $Target += @($path.foreach{$_.split(';')})         ##### $path split on semicolon
  $Target += @($subdirectory.foreach{$_.split(';')}) ##### $subdirectory -split ';'
  $Target | ForEach-Object {
    $_ = @(if ($goHash.Contains($_)) {
      $goHash.$_ -split ';' |  Where-Object { Test-Path $_ }
    } else {$_} )
    $_ | ForEach-Object {
      write-verbose "$(LINE) Target: $_ Current: $((Get-Location).path)"
      Set-Location $_ -ea 0 2>&1
    }
  }
  write-verbose "$(LINE) Current: $((Get-Location).path)"
}
New-Alias Go Set-GoLocation -force -scope global;
New-Alias G  Set-GoLocation -force -scope global

Set-GoAlias
$books = switch ($true) {
  { Test-Path 'c:\books' } { Resolve-Path 'c:\books' }
  { Test-Path (Join-Path (Join-Path $Home 'Downloads')  'Books') } { Resolve-Path (Join-Path (Join-Path $Home 'Downloads')  Books) -ea 0 }
}


$gohash = [ordered]@{
  docs       = "$home\documents"
  down       = "$home\downloads"
  download   = "$home\downloads"
  downloads  = "$home\downloads"
  books      = $books
  ps         = "$books\PowerShell"
  pshell     = "$books\PowerShell"
  profile    = $ProfileDirectory
  pro        = $ProfileDirectory
  txt        = 'c:\txt'
  text       = 'c:\txt'
  esb        = 'c:\esb'
  dev        = 'c:\dev'
}

Function Set-GoAlias {
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

Function Set-GoLocation {
  [CmdletBinding()]param (
    [Parameter(Position='0')][string[]]$path=@(),
    [Parameter(Position='1')][string[]]$subdirectory=@(),
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$args,
    [switch]$pushd,
    [switch]$showInvocation   # for testing
  )
  Function set-SafeJumpLocation {
    $a = $args
    $jumpsTaken = 0
    if (!$a) { try { set-location (Get-Location) } catch { Write-Warning "JL: Failed1" }; return }
                    #set-jumplocation x 4
    foreach ($p in $a) {
      while ($p -is 'array') { $p = $p[0] }
      write-verbose "p:[$p]  a:[$($a -join '] [')]"
      if ($p -and ($p = Resolve-Path $p -ea 0)) {
        write-verbose "p:[$p]  a:[$($a -join '] [')]"
        if (Get-ChildItem $p -ea 0 -force | Where-Object PSIsContainer -eq $True) {
          try { set-location $p ; $jumpsTaken++ } catch { Write-Warning "JL: Failed2" } # Set-JumpLocation
        } else {
          $pd = Split-Path $p
          write-verbose "Target [$p] is a FILE, `n         change to PARENT DIRECTORY [$pd]"
          try { set-location $pd; $jumpsTaken++  } catch { Write-Warning "JL: Failed3" } # Set-JumpLocation
        }
      }
    }
    if (!$jumpsTaken) {
      $a = $a | ForEach-Object { $_ } | ForEach-Object { $_ } # flatten array
      $p = Resolve-Path ($a -join ' ') -ea 0
      write-warning "$(LINE) Joined path: [$p]  a:[$($a -join '] [')]"
      if ($p) { Set-Location $p; return }                  # Set-JumpLocation
      write-warning "$(LINE) a:[$($a -join '] [')]"
      Set-Location @a    ###
    }
  }
  $verbose = $true
  write-verbose "$(LINE) Start In: $((Get-Location).path)"
  if ($showInvocation) { write-warning "$($Myinvocation | out-string )" }
  $InvocationName = $MyInvocation.InvocationName
  if (Get-Command set-jumplocation -ea 0) {
           new-alias jpushd Set-SafeJumpLocation -force
  } else { new-alias jpushd pushd                -force }
  if (!(get-variable gohash -ea 0)) { $goHash = @{} }
  write-verbose "$(LINE) Path: $Path InvocationName: $InvocationName"
  if ($Path.count -eq 1 -and (Test-Path $Path[0])) {
    write-verbose "$(LINE) Path: $Path Sub: $sub"
    try {
      $P = $Path[0]
      ForEach ($sub in ,$subdirectory + $args + '' ) {
        write-verbose "$(LINE) P: $P Sub: $P $sub"
        $JP = Join-Path $P $sub
        if (Test-Path $JP -leaf) { $P = (Resolve-Path $P -parent).ToString()}
        write-verbose "$(LINE) P: $P Sub: $P $sub"
      }
      $Path = @($P)
    } catch {
      write-verbose "$(LINE) $P didn't work with the subs/args"
      jpushd $P
      return
    }  # didn't work so just keep processing
  }
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
    :OuterForEach ForEach ($p in ($Target)) {    #  | ForEach-Object {$_ -split ';'}  ### @($path.foreach{$_.split(';')})
      if ($goHash.Contains($p) -and (Test-Path $goHash.$p)) { $p = $goHash.$p}
      write-verbose "$(LINE) Foreach P: $p"
      if (Test-Path $p -ea 0) {
        $ValidPath += Resolve-Path $p -ea 0
        ForEach ($Sub in ($subdir)) {   #  | ForEach-Object {$_ -split ';'}
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
      if ($true -or $pushd) { jpushd  $ValidPath @args }     #### :HM:
      else        { Set-Location      $ValidPath[0] }
    } else {
      write-verbose "$(LINE) $($Path -join '] [') $($Subdirectory -join '] [')"
      if ($Path -or $Subdirectory) {
        write-verbose "$(LINE) Jump: jpushd $(($Path + $Subdirectory + $args) -join '; ')"
        jpushd ($Path + $Subdirectory) @args
      } else  {
        if ($InvocationName -notin 'go','g','Set-GoLocation','GoLocation') {
          write-verbose "$(LINE) Jump: jpushd $InvocationName args"
          jpushd $InvocationName @args
        } else {
          jpushd $InvocationName @args
          write-verbose "$(LINE) Jump: jpushd $InvocationName"
        }
      }
    }
  }	catch {
    write-error $_
  }
  write-verbose "$(LINE) Current: $((Get-Location).path)"
}
New-Alias Go Set-GoLocation -force -scope global; New-Alias G Set-GoLocation -force -scope global
New-Alias G  Set-GoLocation -force -scope global; New-Alias G Set-GoLocation -force -scope global

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
Function Show-InternetProxy {
  [CmdletBinding()] param()
  $InternetSettingsKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
  $urlEnvironment      = $Env:AutoConfigUrl
  $urlDefault          = 'http://proxyconf.my-it-solutions.net/proxy-na.pac'
  $ProxyValues         = 'AutoConfig ProxyEnable Autodetect'
  write-output "`$Env:AutoConfigUrl        : $($Env:AutoConfigUrl)"
  write-output  "Default proxy             : $urlDefault"
  $Settings = get-itemproperty $InternetSettingsKey -ea 0 | findstr /i $ProxyValues | Sort-Object
    Write-Output "             Registry settings"
    ForEach ($Line in $Settings) {
    Write-Output $Line
  }
}

Function Set-InternetProxy {
  [CmdletBinding()]
  param(
    #[Parameter(ValidateSet='Enable','On','Disable','Off')][string]$State,
    [string]$State,
    [string]$Url,
    [Alias('On' )][switch]$Enable,
    [Alias('Off')][switch]$Disable
  )
  If ($State -match '^(On|Ena)') { $Enable = $True  }
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
    Write-Warning "Specify either Enable or Disable (alias: On or Off)"
    $Verbose = $True
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
  $Settings = get-itemproperty $InternetSettingsKey -ea 0 | findstr /i $ProxyValues | Sort-Object
  ForEach ($Line in $Settings) {
    Write-Verbose $Line -Verbose:$Verbose
  }
}


# Utility Functions (small)
filter Test-Odd  { param([Parameter(valuefrompipeline)][int]$n) [boolean]($n % 2)}
filter Test-Even { param([Parameter(valuefrompipeline)][int]$n) -not (Test-Odd $n)}
Function get-syntax([string]$command='Get-Command') { if ($command) {Get-Command $command -syntax} }   # syntax get-command
new-alias syn get-syntax -force
Function Convert-ObjectToJson ($object, $depth=2) { $object | ConvertTo-Json -Depth $depth }
Function dod { (Get-ChildItem @args) | Sort-Object -prop lastwritetime }
Function don { (Get-ChildItem @args) | Sort-Object -prop fullname }
Function dos { (Get-ChildItem @args) | Sort-Object -prop length }
Function dox { (Get-ChildItem @args) | Sort-Object -prop extension }
Function Privs? {
	if ((whoami /all | Select-Object -string S-1-16-12288) -ne $null) {
		'Administrator privileges enabled'
	} else {
		'Administrator privileges NOT available'
	}
}

Function Get-DayOfYear([DateTime]$date=(Get-Date)) {"{0:D3}" -f ($date).DayofYear}

Function Get-FormattedDate ([DateTime]$Date = (Get-Date)) {
  Get-date "$date" ?f "yyyy-MM-ddTHH:mm:ss-ddd"
}
#([System.TimeZoneInfo]::Local.StandardName) -replace '([A-Z])\w+\s*', '$1'

Function Get-SortableDate {
  [CmdletBinding()]param([DateTime]$Date = (Get-Date))
  Get-Date $date -format 's'
}

#$Myinvocation
#Resolve-Path $MyInvocation.MyCommand -ea 0
#if ($myinvocation.pscommandpath) {$myinvocation.pscommandpath}

write-warning "$(get-date -f 'HH:mm:ss') $(LINE) Before PSReadline "
#$PSReadLineProfile = Join-Path $myinvocation.pscommandpath 'PSReadLineProfile.ps1'
$PSReadLineProfile = Join-Path (Split-Path $PSProfile) 'PSReadLineProfile.ps1'
write-information $PSReadLineProfile
if (Test-Path $PSReadLineProfile) { . $PSReadLineProfile -Force:([Boolean]$ForceForcePSReadlineProfile) }

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
Function 4rank ($n, $d1, $d2, $d) {"{0:P2}   {1:P2}" -f ($n/$d),(1 - $n/$d)}
write-information ("$(LINE) Use Function Get-PSVersion or variable `$PSVersionTable: $(Get-PSVersion)")
Function down {Set-Location "$env:userprofile\downloads"}
Function Get-SerialNumber {Get-WMIObject win32_operatingsystem  | Select-Object -prop SerialNumber}
Function Get-ComputerDomain { Get-WMIObject win32_computersystem | Select-Object -object -prop Name,Domain,DomainRole,DNSDomainName}
Function logicaldrive {Get-WMIObject win32_logicaldisk | Where-Object {$_.drivetype -eq 3} | ForEach-Object {"$($_.deviceid)\"}}
Function fileformat([string[]]$path = @('c:\dev'), [string[]]$include=@('*.txt')) {
  Get-ChildItem -path $path -include $include -recurse -force -ea 0 | Select-Object -Object -prop basename,extension,@{Name='WriteTime';Expression={$_.lastwritetime -f "yyyy-MM-dd-ddd-HH:mm:ss"}},length,directory,fullname | export-csv t.csv -force
}
#region Script Diagnostic & utility Functions
#region Definitions
        # Function Get-CurrentLineNumber
        # Function Get-CurrentFileName
        # Alias   LINE    Get-CurrentLineNumber
        # Alias __LINE__  Get-CurrentLineNumber
        # Alias   FILE    Get-CurrentFileName
        # Alias __FILE__  Get-CurrentFileName
        # Function write-log
        # Function ExitWithCode($exitcode)
        # Function Make-Credential
        # Function Get-ErrorDetail
        # Function MyPSHost
#endregion

Function PSBoundParameter([string]$Parm) {
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
  If ($Host.PrivateDate -and $Host.PrivateDate.ErrorBackgroundColor) {
    $Host.PrivateData.ErrorBackgroundColor   = 'DarkRed'
    $Host.PrivateData.ErrorForegroundColor   = 'White'
    $Host.PrivateData.VerboseBackgroundColor = 'Black'
    $Host.PrivateData.VerboseForegroundColor = 'Yellow'
    $Host.PrivateData.WarningBackgroundColor = 'Black'
    $Host.PrivateData.WarningForegroundColor = 'White'
  }
}
write-warning "$(get-date -f 'HH:mm:ss') $(LINE) After PSReadline "


#---------------- Snippets
# Set-Location (split-path -parent $PSProfile )
# Get-Command *zip*,*7z*,*archive*  | Where-Object {$_.Source -notmatch '\.(cmd|exe|bat)'}
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
write-information "$(get-date -f 'HH:mm:ss') $(LINE) Error count: $($Error.Count)"
<#
$SearchPath = (("$PSProfile;.;" + $env:path) -split ';' | ForEach-Object { join-path $_ 'utility.ps1' } | Where-Object { test-path $_ -ea 0}) -split '\s*\n'
ForEach ($Path in $SearchPath) {
  try {
    $Utility = Join-Path $Path 'utility.ps1'
    if (Test-Path $utility) {
      write-information "$(LINE) Source: $utility"
      .  (Resolve-Path $utility[0]).path
      write-information "$(LINE) Finished sourcing: $utility"
      break
    }
  } catch {
    write-information "$(LINE) Caught error importing $Utility"
    # $_
  }
  write-information "$(LINE) utility.ps1 not found local or on path"
}
#>
#filter dt { if (get-variable _ -scope 0) { get-sortabledate $_ -ea 0 } else { get-sortabledate $args[1] } }
Function dt {param([string[]]$datetime=(get-date)) $datetime | ForEach-Object { get-date $_ -format 'yyyy-MM-dd HH:mm:ss ddd' } }
#Function dt {param([string[]]$datetime=(get-date)) $datetime | ForEach-Object { get-sortabledate $_) -creplace '\dT'  } }

#echo 'Install DOSKey'
#doskey /exename=powershell.exe /macrofile=c:\bat\macrosPS.txt
#del alias:where -ea 0
# Find-file
# where.exe autohotkey.exe 2>$Null
# $env:PathExt
# Search books (or Search Directory Find Books Find Directory Files)  ## :HM:
# Get-ChildItem F:\bt\Programming\Python\*,c:\users\herb\downloads\books\python\* -include *hacking*
# join-path $Books 'Python' -resolve
# Get-ChildItem F:\bt\Programming\Python\*,c:\users\herb\downloads\books\python\* -include *hack* | Select-Object @{Name='LastWrite';E={get-date ($_.LastWriteTime) -f 'yyyy-mm-dd HH:mm'}},Length,Name
# $FileFormat = @{N='LastWrite';E={get-date ($_.LastWriteTime) -f 'yyyy-MM-dd HH:mm'}},'Length','Name';

Function Find-File {
  [CmdletBinding()]param(
    [Parameter(Mandatory=$true)][string[]]$File,
    [string[]]$Location=@(($env:path -split ';') | Select-Object -uniq | Where-Object { $_ -notmatch '^\s*$' }),
    [string[]]$Environment,
    [switch]$Recurse,
    [switch]$Details
  )
  Begin {
    $e = @{}
    Function Extend-File {
      param([string]$name, [string]$ext="$($env:pathext);.PS1")
      If ($name -match '(\.[a-z0-9]{0,5})|\*$') {
        return @($name)
      } elseIf (!$e[$name]) {
        $e[$name] = @($ext -split ';' | Select-Object -uniq | Where-Object {
          $_ -notmatch '^\s*$' } | ForEach-Object { "$($Name)$_" }
        )
      }
      $e[$name]
    }
    $Location += $Environment | ForEach-Object {
      $Location += ";$((Get-ChildItem -ea 0 Env:$_).value)"
    }
    If ($EPath) {$Location += ";$($Env:Path)"}
    $Location = $Location | ForEach-Object { $_ -split ';' } | Select-Object -uniq | Where-Object { $_ -notmatch '^\s*$' }
    write-verbose ("$($Location.Count)`n" + ($Location -join "`n"))
    write-verbose ('-' * 72)
    write-verbose "Recurse: $Recurse"
  }
  Process {
    $File | ForEach-Object {
      $F=$_;
      ($Location | ForEach-Object {
        $L = $_;
        Extend-File $F | ForEach-Object {
          Get-ChildItem -file -ea 0 -recurse:$recurse (Join-Path $L $_)
        }
      }
    )} | ForEach-Object {
      if ($Details) { $_ | Select-Object length,lastwritetime,fullname }
      else { $_.fullname }
    }
  }
  End { write-verbose ('-' * 72) }
}

Function Make-Credential($username, $password) {
  $cred = $null
  $secstr = ConvertTo-SecureString -String $password -AsPlainText -Force
  if ($secstr) {
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$secstr
  }
  return $cred
}

Function Get-ErrorDetail {
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

Function MyPSHost {
  $bit = if ([Environment]::Is64BitProcess) {'64-bit'} else {'32-bit'}
  If ($host = get-host) {
    return "$($host.name) $($host.version) $bit process"
  } else {
    return 'PowerShell host not found'
  }
}

Function Get-PSVersion {
  "$($psversiontable.psversion.major).$($psversiontable.psversion.minor)"
}

<#
General useful commands
 Get-Command *-rsjob*
 history[-10..-1]
#>
Function PSBoundParameter([string]$Parm) {
  return ($PSCmdlet -and $PSCmdlet.MyInvocation.BoundParameters[$Parm].IsPresent)
}
#endregion Definitions
#endregion Script Diagnostic & utility Functions
#---------------- Snippets
# Set-Location (split-path -parent $PSProfile )
# Get-Command *zip*,*7z*,*archive*  | Where-Object {$_.Source -notmatch '\.(cmd|exe|bat)'}
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

if (!(where.exe choco.exe 2>$Null)) {
  "Get Chocolatey: iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
} else {
  where.exe choco.exe 2>$Null
}
if (!(where.exe git.exe 2>$Null)) {
  "Get WindowsGit: & '$PSProfile\Scripts\Get-WindowsGit.ps1'"
} else {
  where.exe git.exe
}

# Temporary Fix es in Profile \ Tools
if (($es = Get-Alias es -ea 0) -and !(Test-Path $es)) { Remove-Item Alias:es -force -ea 0 }
if (!(Get-Command es -ea 0)) { New-Alias es "$ProfileDirectory\Tools\es.exe" }
if ($Quiet -and $informationpreferenceSave) { $global:informationpreference = $informationpreferenceSave }

# try {
# try is at start of script, use for testing
} catch {  #try from top
  write-error "Caught error in profile"
  throw $_
} finally {
  if (!$PSProfileDirectory) {
    $PSProfileDirectory = Split-Path $PSProfile -ea 0
  }
  if (!(Test-Path $PSProfileDirectory)) {
    mkdir (Split-Path $PSProfile -ea 0) -ea 0 -force
  }
  if ((Get-Location) -match '^.:\\Windows') {
    If (Test-Path $PSProfileDirectory) {
      Set-Location $PSProfileDirectory
    } else {
      Set-Location $Home
    }
    if ((Get-Location) -match '^.:\\Windows') { Set-Location \ }
  }
}
if ((Get-Location) -match '^.:\\Windows\\System32$') { Set-Location \ }

write-warning "$(get-date -f 'HH:mm:ss') $(LINE) Completed: $Profile "

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
Alt+F7                ClearHistory                  Remove all items from the command line history (not PowerShell Get-History...
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
Unbound               InvokePrompt                  Erases the current prompt and calls the prompt Function to redis...
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

