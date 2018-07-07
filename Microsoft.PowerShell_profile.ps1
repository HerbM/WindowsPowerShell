#region    Parameters
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
#region    Parameters
$Private:StartTime  = Get-Date
$ErrorCount = $Error.Count

Function Get-Defined {
  [CmdletBinding()][OutputType([Object])]
  Param(
    [Parameter(Mandatory)][Alias('VariableName','VN')]
    [ValidateNotNullorEmpty()][string]$Name
  )
  [boolean](Get-Variable $Name -ea Ignore )
}

Function Get-Value {
  [CmdletBinding()][OutputType([Object])]
  Param(
    [Parameter(Mandatory)][Alias('VariableName','VN')]
    [ValidateNotNullorEmpty()][string]$Name
  )
  If (Get-Variable $Name -ea Ignore) {
     (Get-Variable $Name -ea Ignore -value)
  }
}

Function Get-CurrentLineNumber { $MyInvocation.ScriptLineNumber }
remove-item Alias:LINE -ea Ignore -force
New-Alias -Name LINE -Value Get-CurrentLineNumber -Description 'Returns the caller''s current line number'
$Private:Colors     = @{ForeGroundColor = 'White'; BackGroundColor = 'DarkGreen'}
Write-Host "$(LINE) $(get-date -f 'yyyy-MM-dd HH:mm:ss') PowerShell $($psversiontable.PSVersion.tostring())" @Private:Colors
Write-Host "$(LINE) Starting error count: $ErrorCount" @Private:Colors

$ProfileDirectory   = Split-Path $Profile
$PSProfile          = Resolve-Path -ea Ignore $(
  If ($MyInvocation.MyCommand) { $MyInvocation.MyCommand } else { $Profile }
)
$PSProfile          = If (Get-Value PSProfile) { $PSprofile } else { $Profile }
$PSProfileDirectory = Split-Path $PSProfile
$ProfileLogPath     = $Profile   -replace '\.ps1$','LOG.txt'
$PSProfileLogPath   = $PSProfile -replace '\.ps1$','LOG.txt'
Write-Host "$(LINE) Use `$Profile   for path to Profile: $Profile"   @Private:Colors
Write-Host "$(LINE) Use `$PSProfile for path to Profile: $PSProfile" @Private:Colors
Write-Host "$(LINE) ProfileLogPath: $ProfileLogPath"                 @Private:Colors

Function Get-ExtraProfile {
  [CmdletBinding()]param(
    [String]$Suffix,
    [String[]]$Name=@($Env:UserDomain, $Env:ComputerName, $Env:UserName)
  )
  $Name | ForEach-Object {
    $Extra = Join-Path $ProfileDirectory "Profile$($_)$($Suffix).ps1"
    Write-Verbose $Extra
    If (Test-path $Extra -ea Ignore) {
      $Extra
    }
  }
}

Get-ExtraProfile 'Pre' | ForEach-Object {
  try {
    $Private:Separator = "`n$('=' * 72)`n"
    $Private:Colors    = @{ForeGroundColor = 'Blue'; BackGroundColor = 'White'}
    $Private:StartTimeProfile  = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
    $Private:ErrorCountProfile = $Error.Count
    Write-Host "$($Private:Separator)$($Private:EndTimeProfile) Extra Profile`n$_$($Private:Separator)" @Private:Colors
    . $_
  } catch {
    Write-Error "ERROR sourcing: $_`n`n$_"
  } finally {
    $Private:EndTimeProfile  = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
    $Private:Duration = ((Get-Date $Private:EndTimeProfile) - (Get-Date $Private:StartTimeProfile)).TotalSeconds
    Write-Host "$($Private:Separator)$($Private:EndTimeProfile) Duration:$($Private:Duration) seconds Extra Profile`n$_$($Private:Separator)" @Private:Colors
  }
}

If ($Host.PrivateData -and ($host.PrivateData.ErrorBackgroundColor -as [string])) {
  $host.PrivateData.errorbackgroundcolor   = 'Red'
  $host.PrivateData.errorForeGroundColor   = 'White'
 #$host.PrivateData.verbosebackgroundcolor = 'black'
  $host.PrivateData.debugbackgroundcolor   = 'black'
}

  # 'Continue', 'Ignore', 'Inquire', 'SilentlyContinue', 'Stop', 'Suspend'
  # Begin adding regions, Add cc, c alias/functions
  # Fixed Alt+(,Alt+),Get-DotNetAssembly,Get-RunTime,Add Get-Accelerator,[Accelerators]
  # Temporary Fix to Go(works without Jump), Scripts to path,find and run Local*.ps1"
  # Fix 6.0 problems, PSGallery, Where.exe output, PSProvider
  # Improved Get-ChildItem2, Add-ToolPath,++B,++DosKey,CleanPath,start Get-DirectoryListing,add refs,README.mkdir
  # Show-ConsoleColor,Get-Syntax(aliases),++Select-History,++FullHelp,++d cmds, esf (needs *,? support),++Add-ToolPath,Reduce History Saved
  # Started Add-Path(crude) -- more ToDo notes
  # Used -EA IGNORE for most handled errors
  # Added support for local-only PS1 files: ProfileXPre and ProfileXPost.ps1
  # 7-Zip        http://www.7-zip.org/download.html
  # Git          https://git-scm.com/download/win
  #              https://github.com/git-for-windows/git/releases/download/v2.18.0.windows.1/Git-2.18.0-64-bit.exe
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
  # VirusTotal   https://www.virustotal.com/#/settings/apikey
  # XPDF & Tools PDFToText is the main reason I am adopting this tool:
  #              GUI Program:	https://xpdfreader-dl.s3.amazonaws.com/XpdfReader-win64-4.00.01.exe
  #              CLI Tools: 	https://xpdfreader-dl.s3.amazonaws.com/xpdf-tools-win-4.00.zip
  #              Extra Fonts:	https://xpdfreader-dl.s3.amazonaws.com/xpdf-t1fonts.tar.gz
  #              Source code:	https://xpdfreader-dl.s3.amazonaws.com/xpdf-4.00.tar.gz
  # https://null-byte.wonderhowto.com/how-to/use-google-hack-googledorks-0163566/
  # Add to Scripts, Snippets etc.
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
  # "line1","line2" -join (NL)
  # "line1","line2" -join [environment]::NewLine
  # https://github.com/FriedrichWeinmann/PSReadline-Utilities
  # https://github.com/FriedrichWeinmann/functions
  # PSFramework
  # Install-Module -Scope CurrentUser -Name Assert
  # Chrome key mapper?  chrome://extensions/configureCommands
  # Chrome extensions   chrome://extensions/
  # DSC_PowerCLISnapShotCheck  PowerCLITools  PowerCLI.SessionManager PowerRestCLI
  # PowerShell CodeManager https://bytecookie.wordpress.com/
  # ChocolateyGet
  
try {
  $ProfileScriptDirectories = $ProfileDirectory, $PSProfileDirectory,
            "$ProfileDirectory\Scripts*", "$PSProfileDirectory\Scripts*"
  Join-Path $ProfileScriptDirectories Local*.ps1 -resolve -ea Ignore 2>$Null |
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
  # Clean the $Env:Path
  $Script:AddPath = "$PSScriptRoot\Tools", "$PSScriptRoot\Scripts"
  $SavePath = (($Env:Path -split ';' -replace '(?<=[\w\)])[\\;\s]*$') + $Script:AddPath |
    Where-Object { $_ -and (Test-Path $_) } | Select-Object -uniq) -join ';'
  if ($SavePath) { $Env:Path, $SavePath = $SavePath, $Env:Path }
  Function Measure-CommandPath {
    $env:pathext -split ';' | ForEach-Object {
      (Join-Path ($env:path -split ';') "*$_" -resolve -ea 0) |
      ForEach-Object { Get-Item -literal $_ }
    } | Group-Object DirectoryName -noelement | Sort-Object Count,Name
  }
  Function Get-PSVersion {"$($psversiontable.psversion.major).$($psversiontable.psversion.minor)"}
  Function Test-Administrator {
  ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")
  }
  #Function Test-Administrator { (whoami /all | Select-Object -string S-1-16-12288) -ne $null }
  #if ((whoami /user /priv | Select-Object -string S-1-16-12288) -ne $null) {'Administrator privileges: ENABLED'} #else {'Administrator privileges: DISABLED'}
  if ($AdminEnabled = Test-Administrator) {
           write-information "$(LINE) Administrator privileges enabled"
  } else { write-information "$(LINE) Administrator privileges DISABLED"}
write-warning "$(get-date -f 'HH:mm:ss') $(LINE)"
If ($WinMerge = Join-Path -resolve -ea ignore 'C:\Program*\WinMerge*' 'WinMerge*.exe' |
  ? { $_ -notmatch 'proxy' } | select -first 1) {
  new-alias WinMerge $WinMerge -force -scope Global
}

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
    if ($marker = where.exe PortCheck.exe 2>$Null) {
      Write-Warning "Path is good: $marker"
      return
    } else {
      if (Test-Path (Join-Path $TryPath "Util\PortCheck.exe" -ea ignore)) {
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
                Where-Object  { Test-Path $_ -ea ignore }
try { Add-ToolPath $PlacesToLook } catch { Write-Warning "Caught:  Add-Path"}
Function DosKey {
  param($Pattern='=')
  if ($macros = where.exe 'macros.txt' 2>$Null) {
    Get-Content $macros | Where-Object { $_ -match $Pattern }
  }
}
Function B { if (!$Args) { $args = ,95}  DisplayBrightnessConsole @Args }
Function Get-PSHistory {
  param(
    $UserName = $Env:UserName
  )
  If ($PSHistory) {
    $psh = $PSHistory -replace $Env:UserName, $UserName
    If ($psh -and (Test-Path $psh -ea 0)) {
      (Resolve-Path $psh -ea ignore).path
    } Else {
      Write-Warning "PSHistory for $Username not found '$psh'"
    }
  } Else {
    Write-Warning "PSHistory not found"
  }
}
<#
Function Add-Path {
  [CmdLetBinding()]param(
    [string[]]$Path
  )
  $SpltPath = $Env:Path -split ';'
  ForEach ($Get-ChildItem in Path) {
    $Get-ChildItem = Split-Path -leaf $Get-ChildItem -ea ignore # get just final directory name
    $OnPath = $SplitPath -match "\\$Get-ChildItem$"
    $OnPath =
    #If (! ())
    if (!(Test-Path 'C:\Util')) {
      # $env:path += ';T:\Programs\Herb\util;T:\Programs\Herb\Unx;T:\programs\Herb\Bat'
    }
  }
}
#>

Function Get-NewLine { [environment]::NewLine }; new-alias NL Get-NewLine -force
if (! (Get-Command write-log -type Function,cmdlet,alias -ea ignore)) {
  new-alias write-log write-verbose -force -scope Global -ea ignore
}
#(dir C:\Util\*64.???).fullname | Where { $_ -replace '64(?=\.)' | dir -name -ea ignore } | ForEach-Object { New-Alias $($Name -replace '\.exe') $_ -force -Scope Global }
new-alias kp      'C:\Program Files (x86)\KeePass2\KeePass.exe' -force -scope Global -ea ignore
new-alias KeePass 'C:\Program Files (x86)\KeePass2\KeePass.exe' -force -scope Global -ea ignore
new-alias rdir    Remove-Item  -force -scope Global -ea ignore
new-alias cdir    Set-Location -force -scope Global -ea ignore
new-alias mdir    mkdir        -force -scope Global -ea ignore
new-alias mvdir   move-item    -force -scope Global -ea ignore
new-alias modir   more         -force -scope Global -ea ignore
new-alias moredir more         -force -scope Global -ea ignore
new-alias tdir    Get-Content  -force -scope Global -ea ignore
new-alias typedir Get-Content  -force -scope Global -ea ignore
new-alias ldir    less         -force -scope Global -ea ignore
new-alias lessdir less         -force -scope Global -ea ignore
new-alias l       less         -force -scope Global -ea ignore
Function Set-ItemTime {
  [CmdletBinding(DefaultParameterSetName='Path', SupportsShouldProcess, SupportsTransactions)]
 	param(
 	  [Parameter(ParameterSetName='Path',Position=0,
               ValueFromPipeline,ValueFromPipelineByPropertyName)]
 	  [string[]]$Path=@(Get-ChildItem | Where-Object PSIsContainer -eq $False),
 	  [Parameter(ParameterSetName='LiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
 	  [Alias('PSPath')][string[]]$LiteralPath,
    [Alias('WriteTime','Time','DateTime')]
    [Parameter(Position=1)][DateTime]$Date=(Get-Date),
    [string[]]$Property = @('LastWriteTime'),
 	  [switch]$PassThru,
 	  [string]$Filter,
 	  [string[]]$Include,
 	  [string[]]$Exclude
 	  #[switch]${Force},
 	  #[Parameter(ValueFromPipelineByPropertyName=$true)]
 	  #[pscredential]
 	  #[System.Management.Automation.CredentialAttribute()]
 	  #${Credential})
  )
  Begin   {
    $DateString = Get-Date $Date -f 'yyyy-MM-dd HH:mm:ss'
    Set-StrictMode -Version Latest
    Write-Verbose "Property set: $($PSCmdlet.ParameterSetName)"
  }
  Process {
    If ($PSBoundParameters.ContainsKey('LiteralPath')) {
      $Path = @($PSBoundParameters.LiteralPath)
    }
    ForEach ($Item in $Path) {
      $ShouldProcess = $True
      If (!(Test-Path $Item -ea Ignore)) {
        $NewMessage = "Create $Item to set $($Property -join ', ') to $DateString"
        If ($ShouldProcess = $PSCmdlet.ShouldProcess($Item, $NewMessage)) {
          Write-Verbose "Creating item: $Item - ShouldNew: [$ShouldProcess]"
          New-Item $Item
          $ItemPath = Resolve-Path $Item
          Write-Verbose "Created new item: $ItemPath"
        } else {
          $ItemPath = $Item
          Write-Warning "ShouldNew: [$ShouldProcess]"
          Write-Verbose "Skipped Creation of new item: $ItemPath"
          $ShouldProcess = $False
        }
      } else {
        $ItemPath = Resolve-Path $Item
      }
      $SetMessage =  "Set $($Property -join ', ') to $DateString"
      If ($ShouldProcess -and ($ShouldProcess2 = $PSCmdlet.ShouldProcess($Item, $SetMessage))) {
        Write-Verbose "Setting itemproperty: $ItemPath"
        ForEach ($Prop in $Property) {
          Set-ItemProperty $ItemPath -Name $Prop -Value $Date
        }
        If ($PassThru) { Get-Item $ItemPath }
      } else {
        Write-Verbose "Skipped Setting itemproperty: $ItemPath"
      }
    }
  }
  End { }
}
    ####If ($Date -as [DateTime]) {
    ####} else {
    ####  $ErrorMessage = "Date parameter must be convertible to a valid DateTime"
    ####  Throw $ErrorMessage
    ####  Write-Warning $ErrorMessage
    ####  Get-Date
    ####}
write-warning "$(get-date -f 'HH:mm:ss') $(LINE)"
try {
  $TryPath = $PSProfileDirectory,$ProfileDirectory,'C:\Bat','.' 
  Write-Warning "$(get-date -f 'HH:mm:ss') $(LINE) Try Utility path: $($TryPath -join '; ')"
  If ($Util=(Join-Path $TryPath 'utility.ps1' -ea ignore | Select -First 1)) {
    Write-Warning "Utility: $Util"
    . $Util
    Get-Command Write-Log -syntax
    Write-Log "$(LINE) Using Write-Log from Utility.ps1"
  }
} catch { # just ignore and take care of below
  Write-Log "$(LINE) Failed loading Utility.ps1 $Util"
} finally {}
write-warning "$(get-date -f 'HH:mm:ss') $(LINE) ##338"
if ((Get-Command 'Write-Log' -type Function,cmdlet -ea ignore)) {
  remove-item alias:write-log -force -ea ignore
} else {
  New-Alias Write-Log Write-Verbose -ea ignore
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
#  remove-item alias:write-log -force -ea ignore
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
#       $null = Out-file -enc utf8 -filepath $LogFilePath -input $Entry -append -ea ignore -force
#     } else {
#       $line | Export-Csv -Path $LogFilePath -Append -NoTypeInformation -ea ignore -force -enc ASCII
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
#     if (($L = get-variable MyInvocation -scope 1 -value -ea ignore) -and $L.ScriptLineNumber) {
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
  @((get-childitem 'ENV:Notepad++','ENV:NotepadPlusPlus' -ea ignore).value -split ';'  |
    Where-Object { $_ -match '\S'} |
    ForEach-Object { $_,(Join-Path $_ 'Notepad++*'  2>$Null)} | Where-Object {Test-Path $_ -ea ignore})      +
  (where.exe notepad++ 2>$null)                                +
  (gal np -ea ignore).definition                                    +
  ((get-childitem ENV:prog* -ea ignore).value | Select-Object -uniq        |
    ForEach-Object {Join-Path $_ 'Notepad++*'} | Where-Object {Test-Path $_ -ea ignore})      +
  ('C:\ProgramData\chocolatey\bin',
   'S:\Programs\Notepad++*','S:\Programs\Portable\Notepad++*',
   'T:\Programs\Notepad++*','T:\Programs\Portable\Notepad++*',
   'S:\Programs\Herb\util', 'T:\Programs\Herb\util',
   'D:\wintools\Tools\hm') |
   Get-ChildItem -include 'notepad++*.exe' -excl '.paf.' -file -recurse -ea ignore |
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
              [switch]$FirstPath,
              [switch]$IgnoreAlias
  )
  $Old = Get-Alias $Name -ea Ignore
  if ($IgnoreAlias) { remove-item Alias:$Name -force -ea Ignore }
  $SearchPath = if ($FirstPath) {
    $cmdnames = @(If ($cmd = @(get-command $Name -all -ea Ignore)) {
      $cmd.definition
    })
    $Path + (where.exe $Command 2>$Null) + $cmdnames
  } else {
    @(get-command $Name -all -ea Ignore).definition +
     (where.exe $Command 2>$Null) + $Path
  }
  Remove-Item Alias:$Name -force -ea Ignore
  ForEach ($Location in $SearchPath) {
    if ($Location -and (Test-Path $Location -pathType Leaf -ea Ignore)) {
      new-alias $Name $Location -force -scope Global
      break
    } elseif ( $Location -and $Command -and
              ($Location = Join-Path $Location $Command -ea Ignore) -and
              (Test-Path $Location -pathType Leaf)) {
      new-alias $Name (Join-Path $Location $Command) -force -scope Global
      break
    }
  }
  if (Get-Command $Name -commandtype alias -ea Ignore) {
    write-warning "$(LINE) $Name found: $Location [$((Get-Alias $Name -ea Ignore).definition)]"
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
   'D:\wintools\Tools\hm\notepad++.exe') -FirstPath
Set-ProgramAlias nscp nscp.exe 'C:\Program Files\NSClient++\nscp.exe' -FirstPath
Set-ProgramAlias 7z   7z.exe @('C:Util\7-Zip\app\7-Zip64\7z.exe',
                               'C:\ProgramData\chocolatey\bin\7z.exe',
                               'S:\Programs\7-Zip\app\7-Zip64\7z.exe'
                             ) -FirstPath
# 'Thu, 08 Feb 2018 07:47:42 -0800 (PST)' -replace '[^\d]+$' -as [datetime] 13:47:42 -0800 (PST)'
# 'Thu, 08 Feb 2018 07:47:42 -0800 (PST)' -replace '[^\d]+$' -as [datetime] 13:47:42 -0800 (PST)'
#$raw = 'Thu, 08 Feb 2018 13:47:42 -0800 (PST)'
#$pattern = 'ddd, dd MMM yyyy Get-History:mm:ss zzz \(PST)'
#[DateTime]::ParseExact($raw, $pattern, $null)
if ($MyInvocation.HistoryID -eq 1) {
  if (Get-Command write-information -type cmdlet,Function -ea ignore) {
    $InformationPreference = 'Continue'
    Remove-Item alias:write-information -ea ignore
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
  @(foreach ($key in  $DotNetKey) { Get-ChildItem $key }) | Get-ItemProperty -ea ignore |
    Select-Object @{N='Name';E={$_.pspath -replace '.*\\([^\\]+)$','$1'}},version,
      InstallPath,@{N='Path';E={($_.pspath -replace '^[^:]*::') -replace '^HKEY[^\\]*','HKLM:'}}
}
$DefaultConsoleTitle = 'Windows PowerShell'
If (Test-Administrator) {
  $DefaultConsoleTitle = 'Administrator: Windows PowerShell'
  # https://github.com/PowerShell/PowerShellGet/archive/1.6.0.zip
  try {
    if ((Get-PSVersion) -lt 6.0) {
      If (Get-Package 'Nuget' -ea ignore) {
        write-warning "$(get-date -f 'HH:mm:ss') $(LINE)"
      } else {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
      }
    }
    $PSGallery = Get-PSRepository PSGallery -ea ignore
    if ($PSGallery) {
      #$PSGallery
      if ($PSGallery.InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -name 'PSGallery' -InstallationPolicy 'Trusted' -ea ignore
        $PSGallery = Get-PSRepository -name 'PSGallery'                  -ea ignore
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
Function Update-ModuleList {
  [CmdLetBinding(SupportsShouldProcess = $true,ConfirmImpact='Medium')]
  param(
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [string[]]$name='pscx'
  )
  begin {}
  process {
    foreach ($ModuleName in $Name) {
      $InstalledModule = @(get-module $ModuleName -ea ignore -list | Sort-Object-Object -desc Version)
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
      $FoundModule = find-module $ModuleName -minimum $version -ea ignore |
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
  'Veeam.PowerCLI-Interactions',
  'PSReadLine',
  'PSUtil'
)

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
if (Join-Path $PSProfileDirectory "$($env:UserName).ps1" -ea ignore -ev $Null) {
}
# (Get-IPAddress).ipaddresstostring -match '^10.10'
$ecs       = 'ts.ecs-support.com'
# $ecsts01 = 'ts.ecs-support.com'
# $ecsts02 = 'ts.ecs-support.com'
$j1        = "$($ecs):32793"
$j2        = "$($ecs):32795"
$ts1       = "ecs-DCts01"
$ts2       = "ecs-DCts02"
# Join-Path 'C:\Util','c:\Program*\*','C:\ProgramData\chocolatey\bin\','T:\Programs\Tools\Util','T:\Programs\Util','S:\Programs\Tools\Util','S:\Programs\Util' 'NotePad++.exe' -resolve -ea ignore
# PsExec64.exe -h \\REMOTECOMPUTER qwinsta | find "Active"
# runas /noprofile /netonly /user:"DOMAIN\USERNAME" "mstsc /v:REMOTECOMPUTER /shadow:14 /control"
Function New-RDPSession {
  [CmdLetBinding()]param(
    [Alias('Remote','Target','Server')]$ComputerName,
    [Alias('ConnectionFile','File','ProfileFile')]$path='c:\bat\good.rdp',
    [int]$Width=1350, [int]$Height=730,
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
if ($AdminEnabled -and (get-command 'ScreenSaver.ps1' -ea ignore)) { ScreenSaver.ps1 }
<# Testing ideas #>
Function Merge-Object {
  Param (
    [Parameter(mandatory=$true)]$Object1,
    [Parameter(mandatory=$true)]$Object2
  )
  foreach ($Prop in ($Object2 | gm -membertype *property)) {
    $Object1 |
      Add-Member -MemberType NoteProperty -Name $Prop.name -Value $Object2.$($Prop.name) -ea ignore
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
	if ($hc = import-clixml -first 1 "$Home\Documents\WindowsPowerShell\tt.xml" -ea ignore) {
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
  [CmdletBinding()]param(
    $UserName,
    [Alias('RemoteComputer','TargetComputer','ServerComputer')]
      $ComputerName=$Env:ComputerName, # /SERVER:servername
    [Alias('Me','My','Mine')][switch]$Current
  )
  $WinSta = qwinsta /server:$ComputerName 2>$Null | Select-Object -skip 1
  If ($WinSta) {
    write-verbose "Winsta count: $($WinSta.count)"
  }  
  $WinSta | ForEach-Object {
    write-verbose "WinStaLine: $_"
    # SESSIONNAME       USERNAME                 ID  STATE   TYPE        DEV
    # rdp-tcp#89        jramirez                 10  Active
    ForEach ($COL in @(2,19,56,68)) {
      $_ = $_ -replace "^(.{$($COL)})\s{3}", '$1###'
    }
    write-verbose "WinStaLine: $_"
    $S=[ordered]@{ ComputerName = $ComputerName };
    $O=[ordered]@{ ComputerName = $ComputerName };
    [boolean]$O.Current =  $_ -match '^>'
    $null,$S.Name,$S.UserName,$S.ID,$S.State,$S.Type,$S.Device,$null = $_ -split '[>\s]+'
    ForEach ($Key in $S.Keys) { $O.$Key = $S.$Key -replace '^###$' }
    $Session = [PSCustomObject]$O
    if ($Current)  { $Session = $Session | Where-Object Current  -eq    $True     }
    if ($UserName) {
      if ($UserName -match '(^|\w)\*') {
        $Session = $Session | Where-Object UserName -like  $UserName
      } else {
        $Session = $Session | Where-Object UserName -match $UserName
      }
    }
    if ($Session)  { Set-DefaultPropertySet $Session @('ComputerName','Current','UserName','ID','State')}
  }
}
New-Alias ws  Get-WinStaSession -force -scope Global
New-Alias gws Get-WinStaSession -force -scope Global
Function Start-Shadow {
  [CmdLetBinding()]param(
    [Alias('SessionID','ID','UserId')]$UserName,
    [Alias('Remote','Target','Server')]$ComputerName=$Env:Computername, # /SERVER:servername
    [int]$Width=1350,
    [int]$Height=730,
    [Alias('NoAssist','NoRemoteControl')][switch]$NoControl,
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$RemArgs
  )
  $argX = $args
  If ($ID = $UserName -as [uint16]) {
  } else {
    If ($session = Get-WinStaSession $UserName $ComputerName -verbose:$False | Select -first 1) {
      If ($Session.Current -and ($Env:Computername -eq $Session.ComputerName)) {
        throw "You cannot shadow yourself ($UserName) on same machine: $($Session.ComputerName)"
      } else {
        $Id = $Session.ID
      }
    }
  }
  If ($ID) {
    $Parameters = @("/v:$ComputerName", "/Shadow:$Id") +
                  @("/w:$Width", "/h:$Height")         +
                  $argX
    If (!$NoControl) { $Parameters += '/Control' }
    Write-Verbose "mstsc $Parameters"
    mstsc @Parameters
  }
}
New-Alias rs     Start-Shadow -force
New-Alias Shadow Start-Shadow -force

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
  [CmdletBinding(DefaultParameterSetName='Name')]Param(
    [String[]]$Name,
    [String]$Scope = 'Local',
    [switch]$UseTransaction
  )
  If ($PSBoundParameters.ContainsKey('Name'))  {
    $Name = $Name | ForEach-Object {
      If (Test-Path $_ -ea Ignore) { (Resolve-Path $Name).Drive } Else { $Name }
    }
    $PSBoundParameters.Name = $Name -replace '(:.*)'
  }
  $PSBoundParameters.PSProvider = 'FileSystem'
  Get-PSDrive @PSBoundParameters
}
Function Get-Free {
  [CmdletBinding(DefaultParameterSetName='Name')]Param(
    [String[]]$Name,
    [String]$Scope = 'Local',
    [switch]$UseTransaction
  )
  If ($PSBoundParameters.ContainsKey('Name'))  {
    $Name = $Name | ForEach-Object {
      If (Test-Path $_ -ea Ignore) { (Resolve-Path $Name).Drive } Else { $Name }
    }
    $PSBoundParameters.Name = $Name -replace '(:.*)'
  }
  $PSBoundParameters.PSProvider = 'FileSystem'
  Get-PSDrive @PSBoundParameters | Where-Object Used -ne '' |
    select used,free,root,currentlocation
}
#  Get-PSVolume
# (Get-WMIObject win32_volume ) | Where-Object {$_.DriveLetter -match '[A-Z]:'} |
#  ForEach-Object { "{0:2} {0:2} {0:9} {S:9} "-f $_.DriveLetter, $_.DriveType, (Get-DriveTypeName $_.DriveType), $_.Label, ($_.Freespace / 1GB)}
#  # % {"$($_.DriveLetter) $($_.DriveType) $(Get-DriveTypeName $_.DriveType) $($_.Label) $($_.Freespace / 1GB)GB"}
#}
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
    [string]$Pattern,
    [uint16]$Count,
    $Exclude,
    [Switch]$ShowID,
    [Alias('ID','Object','FullObject')][switch]$HistoryInfo
  )
  If ($PSBoundParameters.Contains('ShowID')) {
    $ShowID = [boolean]$ShowID
    $PSBoundParameters.Remove('ShowID')
  }
  (get-history @PSBoundParameters).commandline
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
Function Get-Syntax {
  param(
  )
  $Result = get-command -syntax @args
  write-warning "result: $Result"
  Foreach ($R in $Result) {
    If ($R -and $R -match '^(["'']?.+["'']?(?!= ))|(\S+)$' -and $R -notmatch '^[\[\-]<') {
      "Get-Command $R -synax -ea ignore"
      Get-Command $R -syntax -ea ignore
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
  # write-verbose "$(& 'C:\Program Files\WindowsPowerShell\Modules\Pscx\3.2.1.0\Apps\EchoArgs.exe' $target @args)"
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
Remove-Item Alias:a -force -ea ignore 2>$Null
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
    [Parameter()]$OFS=$(Get-Variable OFS -scope 1 -ea ignore -value),
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
    [Parameter()]$OFS=$(Get-Variable OFS -scope 1 -ea ignore -value),
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
  If (!(Test-Path Variable:Global:MaxPromptLength -ea ignore 2>$Null)) { $MaxPrompt = 45 }
  $loc = (Get-Location).ProviderPath # -replace '^[^:]*::'
  $Sig = " |>$('>' * $nestedPromptLevel)"
  if (Test-Path Variable:Global:MaxPromptLength) {
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
        (Get-Variable MaxPromptLength -ea ignore 2>$Null))) {
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
        Split-Path -ea ignore $_.invocationinfo.PSCommandPath -Leaf
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
Function Get-Property {
  [CmdletBinding()]param(
    [Parameter(ValueFromPipeline)][psobject]$object,
    [switch]$AsHash
  )
  Process {
    If ($AsHash) {
      $Property = [ordered]@{}
      $Object.psobject.get_properties() | ForEach-Object {
        $Property += @{ $_.Name = $_.Value }
      }
      $Property
    } else {
      $Object.psobject.get_properties()
    }
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
try {
  $ECSTraining = "\Training"
  $SearchPath  = 'C:\',"$Home\Downloads","T:$ECSTraining","S:$ECSTraining"
  $Books = Join-Path $SearchPath 'Books' -ea ignore | Select-Object -First 1
} catch {
  $Books = $PSProfile
}  # just ignore

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
# Import-Module "$Home\Documents\WindowsPowerShell\Set-LocationFile.ps1"
. "$Home\Documents\WindowsPowerShell\Set-LocationFile.ps1"
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
  if (Get-Command set-jumplocation -ea ignore) {
           new-alias jpushd Set-JumpLocation -force -scope Global
  } else { new-alias jpushd pushd            -force -scope Global }
  if (!(get-variable gohash -ea ignore)) { $goHash = @{} }
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
      if (Test-Path $p -ea ignore) {
        $ValidPath += Resolve-Path $p -ea ignore
        ForEach ($Sub in ($subdir)) {   #  | ForEach-Object {$_ -split ';'}
          write-verbose "$(LINE) $p sub: $sub"
          $TryPath = Join-Path (Resolve-Path $pr -ea ignore) $Sub
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
  if (!(get-variable gohash -ea ignore)) { $goHash = @{} }
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
      Set-Location $_ -ea ignore 2>&1
    }
  }
  write-verbose "$(LINE) Current: $((Get-Location).path)"
}
New-Alias Go Set-GoLocation -force -scope global;
New-Alias G  Set-GoLocation -force -scope global
Set-GoAlias

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
      if ($p -and ($p = Resolve-Path $p -ea ignore)) {
        write-verbose "p:[$p]  a:[$($a -join '] [')]"
        if (Get-ChildItem $p -ea ignore -force | Where-Object PSIsContainer -eq $True) {
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
      $p = Resolve-Path ($a -join ' ') -ea ignore
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
  if (Get-Command set-jumplocation -ea ignore) {
           new-alias jpushd Set-SafeJumpLocation -force
  } else { new-alias jpushd pushd                -force }
  if (!(get-variable gohash -ea ignore)) { $goHash = @{} }
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
      if (Test-Path $p -ea ignore) {
        $ValidPath += Resolve-Path $p -ea ignore
        ForEach ($Sub in ($subdir)) {   #  | ForEach-Object {$_ -split ';'}
          write-verbose "$(LINE) $p sub: $sub"
          $TryPath = Join-Path (Resolve-Path $pr -ea ignore) $Sub
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

Function Set-GoLocation {
  [CmdletBinding()]param (
    [Parameter(Position='0')][string[]]$path=@(),
    [Parameter(Position='1')][string[]]$subdirectory=@(),
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$args,
    [switch]$pushd,
    [switch]$showInvocation   # for testing
  )
  write-verbose "$(LINE) Start In: $((Get-Location).path)"
  if ($showInvocation) { write-warning "$($Myinvocation | out-string )" }
  $InvocationName = $MyInvocation.InvocationName
  if (!(get-variable gohash -ea ignore)) { $goHash = @{} }
  write-verbose "$(LINE) Path: $Path InvocationName: $InvocationName"
  try {
    if ($goHash.Contains($InvocationName) -and
        (Test-Path $goHash.$InvocationName -ea Ignore)
       ) {
      cd $goHash.$InvocationName
      If ($Path -and ($p = Resolve-Path $Path[0] -ea 0)) {
        write-verbose "$(LINE) $p"
        cd $p.path
      }
    } elseif ($goHash.Contains($Path[0]) -and
        (Test-Path $goHash.$($Path[0]) -ea Ignore)) {
      cd $goHash.$($Path[0])
      If ($Subdirectory -and ($p = Resolve-Path $Subdirectory[0] -ea ignore)) {
        write-verbose "$(LINE) $p"
        cd $p.path
      }
    }  
  }	catch {
    write-error $_
  }
  write-verbose "$(LINE) Current: $((Get-Location).path)"
}

New-Alias Go Set-GoLocation -force -scope global; New-Alias G Set-GoLocation -force -scope global
New-Alias G  Set-GoLocation -force -scope global; New-Alias G Set-GoLocation -force -scope global

Function Show-InternetProxy {
  [CmdletBinding()] param()
  $InternetSettingsKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
  $urlEnvironment      = $Env:AutoConfigUrl
  $urlDefault          = 'http://proxyconf.my-it-solutions.net/proxy-na.pac'
  $ProxyValues         = 'AutoConfig ProxyEnable Autodetect'
  write-warning "`$Env:AutoConfigUrl        : $($Env:AutoConfigUrl)"
  write-warning  "Default proxy             : $urlDefault"
  $Settings = get-itemproperty $InternetSettingsKey -ea ignore | findstr /i $ProxyValues | Sort-Object
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
  $urlCurrent          = (get-itemproperty $InternetSettingsKey $AutoConfigURL     -ea ignore).$AutoConfigURL
  $urlSaved            = (get-itemproperty $InternetSettingsKey $AutoConfigURLSave -ea ignore).$AutoConfigURLSAVE
  $urlDefault          = 'http://proxyconf.my-it-solutions.net/proxy-na.pac'
  If ($Enable -eq $Disable) {
    Write-Warning "Specify either Enable or Disable (alias: On or Off)"
    $Verbose = $True
  } elseif ($Disable) {
    if ($urlCurrent) {
      set-itemproperty $InternetSettingsKey $AutoConfigURLSave $urlCurrent -force -ea ignore
      remove-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" 'AutoConfigURL' -ea ignore
    }
    Set-ItemProperty $InternetSettingsKey $AutoDetect  0 -force -ea ignore
    Set-ItemProperty $InternetSettingsKey $ProxyEnable 0 -force -ea ignore
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
    Set-Itemproperty $InternetSettingsKey $AutoConfigURL $url -force -ea ignore
    Set-ItemProperty $InternetSettingsKey $AutoDetect    1    -force -ea ignore
    Set-ItemProperty $InternetSettingsKey $ProxyEnable   1    -force -ea ignore
  }
  $Settings = get-itemproperty $InternetSettingsKey -ea ignore | findstr /i $ProxyValues | Sort-Object
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
#Resolve-Path $MyInvocation.MyCommand -ea ignore
#if ($myinvocation.pscommandpath) {$myinvocation.pscommandpath}
write-warning "$(get-date -f 'HH:mm:ss') $(LINE) Before PSReadline "
#$PSReadLineProfile = Join-Path $myinvocation.pscommandpath 'PSReadLineProfile.ps1'
$PSReadLineProfile = Join-Path (Split-Path $PSProfile) 'PSReadLineProfile.ps1'
write-information $PSReadLineProfile
$ForcePSReadline = $PSBoundParameters.ContainsKey('ForcePSReadline') -and ([Boolean]$ForcePSReadline)
if (Test-Path $PSReadLineProfile) {
  try {
    . $PSReadLineProfile -ForcePSReadline:$ForcePSReadline
  } catch {
    Write-Error "Caught error in PSReadlineProfile: $PSReadlineProfile`n$_"
  }
}
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
  Get-ChildItem -path $path -include $include -recurse -force -ea ignore | Select-Object -Object -prop basename,extension,@{Name='WriteTime';Expression={$_.lastwritetime -f "yyyy-MM-dd-ddd-HH:mm:ss"}},length,directory,fullname | export-csv t.csv -force
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
if ($Private:PSRealineModule = Get-Module 'PSReadline' -ea ignore) {
  set-psreadlinekeyhandler -chord 'Tab'            -Func TabCompleteNext      ### !!!!!
  set-psreadlinekeyhandler -chord 'Shift+Tab'      -Func TabCompletePrevious  ### !!!!!
  If ($Private:PSRealineModule.Version  -lt [version]'2.0.0') {
    set-psreadlinekeyhandler -chord 'Shift+SpaceBar' -Func Complete             ### !!!!!
    Set-PSReadLineOption -ForeGround Yellow  -Token None
    Set-PSReadLineOption -ForeGround Green   -Token Comment  -back DarkBlue
    Set-PSReadLineOption -ForeGround Green   -Token Keyword
    Set-PSReadLineOption -ForeGround Cyan    -Token String
    Set-PSReadLineOption -ForeGround Cyan    -Token Operator
    Set-PSReadLineOption -ForeGround Green   -Token Variable
    Set-PSReadLineOption -ForeGround Yellow  -Token Command
    Set-PSReadLineOption -ForeGround Green   -Token Parameter
    Set-PSReadLineOption -ForeGround White   -Token Type
    Set-PSReadLineOption -ForeGround White   -Token Number
    Set-PSReadLineOption -ForeGround White   -Token Member
  } else {
    Set-PSReadlineOption -Colors @{
      ContinuationPrompt = [ConsoleColor]::Magenta     ##  color of the
      Emphasis           = [ConsoleColor]::Magenta     ##  emphasis color, e.g. th
      Error              = [ConsoleColor]::Magenta     ##  error color, e.g. in the p
      Selection          = [ConsoleColor]::Magenta     ##  color to highlight the
      Default            = [ConsoleColor]::yellow      ##  default token color.
      Comment            = [ConsoleColor]::green       ##  comment token color.
      Keyword            = [ConsoleColor]::Yellow      ##  keyword token color.
      String             = [ConsoleColor]::white       ##  string token color.
      Operator           = [ConsoleColor]::cyan        ##  operator token color.
      Variable           = [ConsoleColor]::Green       ##  variable token color.
      Command            = [ConsoleColor]::Yellow      ##  command token color.
      Parameter          = [ConsoleColor]::green       ##  parameter token color.
      Type               = [ConsoleColor]::White       ##  type token color.
      Number             = [ConsoleColor]::White       ##  number token color.
      Member             = [ConsoleColor]::White       ##  member name token color.
    }
  }
}

If ($Host.PrivateData -and ($host.PrivateData.ErrorBackgroundColor -as [string])) {
  $Host.PrivateData.ErrorBackgroundColor   = 'DarkRed'
  $Host.PrivateData.ErrorForegroundColor   = 'White'
  $Host.PrivateData.VerboseBackgroundColor = 'Black'
  $Host.PrivateData.VerboseForegroundColor = 'Yellow'
  $Host.PrivateData.WarningBackgroundColor = 'Black'
  $Host.PrivateData.WarningForegroundColor = 'White'
}
write-warning "$(get-date -f 'HH:mm:ss') $(LINE) After PSReadline "

write-information "$(get-date -f 'HH:mm:ss') $(LINE) Error count: $($Error.Count)"
<#
$SearchPath = (("$PSProfile;.;" + $env:path) -split ';' | 
   ForEach-Object { join-path $_ 'utility.ps1' } | 
   Where-Object { test-path $_ -ea ignore}) -split '\s*\n'
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
#filter dt { if (get-variable _ -scope 0) { get-sortabledate $_ -ea ignore } else { get-sortabledate $args[1] } }
Function dt {param([string[]]$datetime=(get-date)) $datetime | ForEach-Object { get-date $_ -format 'yyyy-MM-dd HH:mm:ss ddd' } }
#Function dt {param([string[]]$datetime=(get-date)) $datetime | ForEach-Object { get-sortabledate $_) -creplace '\dT'  } }
#echo 'Install DOSKey'
#doskey /exename=powershell.exe /macrofile=c:\bat\macrosPS.txt
#del alias:where -ea ignore
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
      $Location += ";$((Get-ChildItem -ea ignore Env:$_).value)"
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
          Get-ChildItem -file -ea ignore -recurse:$recurse (Join-Path $L $_)
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
Function Get-PSHost {
  $bit = if ([Environment]::Is64BitProcess) {'64-bit'} else {'32-bit'}
  If ($Host) {
    return "$($Host.name) $($host.version) $bit process"
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
if (!(Invoke-Command { where.exe choco.exe 2>$Null } -ea Ignore)) {
  "Get Chocolatey: iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
} else {
  where.exe choco.exe 2>$Null
}
if (!(Invoke-Command { where.exe git.exe 2>$Null } -ea Ignore)) {
  "Get WindowsGit: & '$PSProfile\Scripts\Get-WindowsGit.ps1'"
} else {
  where.exe git.exe
}
# Temporary Fix es in Profile \ Tools
if (($es = Get-Alias es -ea ignore) -and !(Test-Path $es)) { Remove-Item Alias:es -force -ea ignore }
if (!(Get-Command es -ea ignore)) { New-Alias es "$ProfileDirectory\Tools\es.exe" }
if ($Quiet -and $informationpreferenceSave) { $global:informationpreference = $informationpreferenceSave }
# try {
# try is at start of script, use for testing
} catch {  #try from top
  write-error "Caught error in profile"
  throw $_
} finally {
  if (!$PSProfileDirectory) {
    $PSProfileDirectory = Split-Path $PSProfile -ea ignore
  }
  if (!(Test-Path $PSProfileDirectory)) {
    mkdir (Split-Path $PSProfile -ea ignore) -ea ignore -force
  }
  if ((Get-Location) -match '^.:\\Windows') {
    If (Test-Path $PSProfileDirectory) {
      pushd $PSProfileDirectory
    } else {
      pushd $Home
    }
    if ((Get-Location) -match '^.:\\Windows') { pushd \ }
  }
}
if ((Get-Location) -match '^.:\\Windows\\System32$') { pushd \ }
$PSDefaultParameterValues['Get-ChildItem:Force'] = $True

Get-ExtraProfile 'Post' | ForEach-Object {
  try {
    $Private:Separator = "`n$('=' * 72)`n"
    $Private:Colors    = @{ForeGroundColor = 'Blue'; BackGroundColor = 'White'}
    $Private:StartTimeProfile  = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
    $Private:ErrorCountProfile = $Error.Count
    Write-Host "$($Private:Separator)$($Private:EndTimeProfile) Extra Profile`n$_$($Private:Separator)" @Private:Colors
    . $_
  } catch {
    Write-Error "ERROR sourcing: $_`n`n$_"
  } finally {
    $Private:EndTimeProfile  = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
    $Private:Duration = ((Get-Date $Private:EndTimeProfile) - (Get-Date $Private:StartTimeProfile)).TotalSeconds
    Write-Host "$($Private:Separator)$($Private:EndTimeProfile) Duration:$($Private:Duration) seconds Extra Profile`n$_$($Private:Separator)" @Private:Colors
  }
}

If (($PSRL = Get-Module PSReadLine -ea 0) -and ($PSRL.version -ge [version]'2.0.0')) {
  Remove-PSReadLineKeyHandler ' ' -ea Ignore
}

$Private:Duration = ((Get-Date) - $Private:StartTime).TotalSeconds
Write-Warning "$(LINE) $(get-date -f 'HH:mm:ss') New errors: $($Error.Count - $ErrorCount)"
Write-Warning "$(LINE) Duration: $Private:Duration Completed: $Profile"
