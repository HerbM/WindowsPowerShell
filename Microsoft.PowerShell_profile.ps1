<#
.Synopsis
  Herb Martin's profile
.Notes
  Herb Martin's profile
#>
#region    Parameters
[CmdLetBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param (
                                                       [switch]$Force,
                                                       [switch]$RunForce,
  [Alias('DotNet')]                                    [switch]$ShowDotNetVersions,
  [Alias('Modules')]                                   [switch]$ShowModules,
  [Alias('IModules')]                                  [switch]$InstallModules,
                                                       [switch]$ForceModuleInstall,
  [ValidateSet('AllUsers','CurrentUser')]              [string]$ScopeModule='AllUsers',
  [Parameter(ValueFromRemainingArguments=$true)]       [string[]]$RemArgs,
  [Alias('ClobberAllowed')]                            [switch]$AllowClobber,
  [Alias('SilentlyContinue')]                          [switch]$Quiet,
  [Alias('PSReadlineProfile','ReadlineProfile','psrl')][switch]$PSReadline,
  [Alias('ForcePSReadlineProfile','fpsrl')]            [switch]$ForcePSReadline,
                                                       [switch]$UpdatePackageManager
  #[Alias('IAc','IAction','InfoAction')]
  #[ValidateSet('SilentlyContinue','')]                                  [switch]$InformationAction
)

Set-StrictMode -off

If (!$RunForce) {  
  If ($Host.Version -lt [Version]'7.1.9' -and $Host.Version -gt [Version]'6.0.0') {
    "=============================================="
    $Host | Select Name,Version,InstanceID
    ""
    $MyInvocation.ScriptName
    "`nSkipping profile for VS Code etc."
    RETURN     #### <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  }
}

$Script:PSLog = "$Home\PowerShellLog.txt"
Get-Date -Format 's' >> $Script:PSLog
'-' * 60      | Format-List * -force | Out-String >> $Script:PSLog
$MyInvocation | Format-List * -force | Out-String >> $Script:PSLog
$Host         | Format-List * -force | Out-String >> $Script:PSLog
'=' * 60      | Format-List * -force | Out-String >> $Script:PSLog
If ((Get-Variable Env:NoPSProfile -value -ea Ignore) -or
     (Get-Variable Env:SkipPSProfile -value -ea Ignore)) {
  Write-Host "Skipping PS Profile due to environment settings" -Fore Yellow -Back DarkRed
  return
}
#region    Parameters
If ((Get-Item Env:NoProfile -ea Ignore) -and $Env:NoProfile.Trim() -match '^(T|Y|Skip)' ) {
  Write-Host "  PowerShell skip profile `$Env:NoProfile = [$($Env:NoProfile)]" -fore 'blue' -back 'Green'
  ForEach ($Key in $PSBoundParameters.Keys) {
    Write-Host "  $Key = $($PSBoundParameters.$Key)" -fore 'blue' -back 'Green'
  }
  Exit
}
$Private:StartTime  = Get-Date
$ErrorCount = $Error.Count
If (!(Get-Command Write-Information -ea 0)) { New-Alias Write-Information Write-Host -Scope Global }

remove-item alias:type       -force -ea Ignore
new-alias   type Get-Content -force -scope Global -ea Ignore

New-Alias -Name LINE -Value Get-CurrentLineNumber -Description 'Returns the current (caller''s) line number in a script.' -force     -ea Ignore
New-Alias -Name __LINE__ -Value Get-CurrentLineNumber -Description 'Returns the current (caller''s) line number in a script.' -force -ea Ignore
New-Alias -Name FILE -Value Get-CurrentFileName -Description 'Returns the name of the current script file.' -force                   -ea Ignore
New-Alias -Name FLINE -Value Get-CurrentFileLine -Description 'Returns the name of the current script file.' -force                  -ea Ignore
New-Alias -Name FILE1 -Value Get-CurrentFileName1 -Description 'Returns the name of the current script file.' -force                 -ea Ignore
New-Alias -Name __FILE__ -Value Get-CurrentFileName -Description 'Returns the name of the current script file.' -force               -ea Ignore
New-Alias TV  Test-Variable -Force -ea Ignore
New-Alias TVN Test-Variable -Force -ea Ignore

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

Function ConvertFrom-FileTime {
  [CmdletBinding()][OutputType([DateTime],[String])]Param(
    [Parameter(Mandatory)][Int64]$FileTime,    # 131775519645343599
    [string]$Format='',
    [switch]$Sortable
  )
  try {
    If ($dt = [datetime]::FromFileTime($FileTime) ) {
      If ($Sortable) { $Format = 's'              }
      If ($Format)   { $dt = "{0:$Format}" -f $dt }
    }
    $dt
  } catch { }  # Just return $Null, no need to do more
}

# $LastLogon = ((nslookup $env:userdnsdomain | select -skip 3 ) -replace '.*\s+([\d.]{7,})?.*','$1').where{$_} | % { get-aduser martinh -Properties *  -server $_ } | Select name,@{N='LastLogon';E={ConvertFrom-FileTIme -sort $_.LastLogon}},LastLogonDate,@{N='LastLogonTimeStamp';E={ConvertFrom-FileTIme -sort $_.LastLogonTimeStamp}} 131775519645343599

Function Get-CurrentLineNumber { $MyInvocation.ScriptLineNumber }
remove-item Alias:LINE -ea Ignore -force
New-Alias -Name LINE -Value Get-CurrentLineNumber -force -ea Ignore -Description 'Returns the caller''s current line number'
$Private:Colors     = @{ForeGroundColor = 'White'; BackGroundColor = 'DarkGreen'}
Write-Host "$(LINE) $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') PowerShell $($psversiontable.PSVersion.tostring())" @Private:Colors
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
If (${Function:Help} -match ($PagerPattern = '(\$IsWindows)\s*\)')) {
  $Function:Help = ${Function:Help} -replace $PagerPattern, '$1 -and !(Get-Command less.exe))'
} Else { Write-Verbose "${Function:Help}" }


<#
.Synopsis
  Locate pre & post load profiles to run
.Description
  Check for ComputerDomain, UserDomain, ComputerName, UserName profiles
  to run them either before (pre) or after the main profile (post)

  Will generate/locate
    $ProfileDirectory\Profile + NAME + Suffix + .ps1
.Parameter Suffix
  Usually Pre or Post
  Will generate/locate
    $ProfileDirectory\Profile + NAME + Suffix + .ps1
#>
If (!(Get-Command Get-WmiObject -ea Ignore)) {
  New-Alias Get-WMIObject Get-CIMInstance -force -scope Global -ea Ignore
  New-Alias gwmi          Get-CIMInstance -force -scope Global -ea Ignore
}
Function Get-ExtraProfile {
  [CmdletBinding()]param(
    [String]$Suffix,
    [String[]]$Name = (@((Get-WMIObject win32_computersystem).Domain) +
      @((nbtstat  -n) -match '(?-i:<00>\s+GROUP\b)' -replace
        '^\s*(\S+)\s*(?-i:<00>\s+GROUP\b).*$', '$1') +
      $Env:UserDomain + $Env:ComputerName + $Env:UserName | Select-Object -Uniq),
    [switch]$PreloadProfile,
    [switch]$PostloadProfile
  )
  If ($PreLoadProfile)  { $Name = @($Name) + '' }
  If ($PostLoadProfile) { $Name = @('') + $Name }
  $Name | Where-Object {
    If ($Extra = Join-Path $ProfileDirectory "Profile$($_)$($Suffix).ps1" -ea Ignore -resolve) {
      Write-Verbose $Extra
      $Extra
    }
  } | ForEach-Object { $Extra } | Select-Object -uniq
}


Function Get-ProcessFile {
  (Get-Process @args).Where{$_.Name -notin 'System','Idle'} |
    Sort-Object -unique name,path | Get-Process -FileVersionInfo
}

Function Get-ProcessUser {
  $args = $args.Where{'IncludeUserName' -notmatch $_ } |
  Get-Process @args -IncludeUserName
}

$UsePreloadProfile = [Boolean](Get-Variable UsePreloadProfile -value -ea Ignore)
Get-ExtraProfile 'Pre' -PreloadProfile:$UsePreloadProfile | ForEach-Object {
  try {
    $Private:Separator = "`n$('=' * 72)`n"
    $Private:Colors    = @{ForeGroundColor = 'Blue'; BackGroundColor = 'White'}
    $Private:StartTimeProfile  = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $Private:ErrorCountProfile = $Error.Count
    Write-Host "$($Private:Separator)$($Private:EndTimeProfile) Extra Profile`n$_$($Private:Separator)" @Private:Colors
    . $_
  } catch {
    Write-Error "ERROR sourcing: $_`n`n$_"
  } finally {
    $Private:EndTimeProfile  = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
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
  #              GUI Program:  https://xpdfreader-dl.s3.amazonaws.com/XpdfReader-win64-4.00.01.exe
  #              CLI Tools:   https://xpdfreader-dl.s3.amazonaws.com/xpdf-tools-win-4.00.zip
  #              Extra Fonts:  https://xpdfreader-dl.s3.amazonaws.com/xpdf-t1fonts.tar.gz
  #              Source code:  https://xpdfreader-dl.s3.amazonaws.com/xpdf-4.00.tar.gz
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
  #         Get-WMIObject win32_service -filter 'name = "everything"' | select name,StartMode,State,Status,Processid,StartName,DisplayName,PathName | ft
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
  $Global:Scripts = "$PSScriptRoot\Scripts"
  $Global:Tools   = "$PSScriptRoot\Tools"
  $Script:AddPath = $Tools, $Scripts
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
           Write-Information "$(LINE) Administrator privileges enabled"
  } else { Write-Information "$(LINE) Administrator privileges DISABLED"}
write-warning "$(Get-Date -Format 'HH:mm:ss') $(LINE)"
If ($WinMerge = Join-Path -resolve -ea ignore 'C:\Program*\WinMerge*' 'WinMerge*.exe' |
  ? { $_ -notmatch 'proxy' } | select -first 1) {
  new-alias WinMerge $WinMerge -force -scope Global
}

#Clean the $Env:Path
$SavePath = ($Env:Path -split ';' -replace '(?<=[\w\)])[\\;\s]*$' |
             Where-Object { $_ -and (Test-Path $_) } |
             select -uniq) -join ';'
if ($SavePath) { $Env:Path, $SavePath = $SavePath, $Env:Path }
Function Add-ToolPath {
  [CmdLetBinding()]param(
    [string[]]$Path
  )
  ForEach ($TryPath in $Path) {
    if (!(where.exe /q PortCheck.exe)) {
      Write-Warning "Path is good: $(where.exe PortCheck.exe)"
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
write-warning "$(Get-Date -Format 'HH:mm:ss') $(LINE)"
$PlacesToLook = 'C:\','T:\Programs\Herb','T:\Programs\Tools','T:\Programs',
                'S:\Programs\Tools','S:\Programs\Herb''S:\Programs'        |
                Where-Object  { Test-Path $_ -ea ignore }
try { Add-ToolPath $PlacesToLook } catch { Write-Warning "Caught:  Add-Path"}
Function DosKey {
  param($Pattern='=')
  if (!(where.exe 'macros.txt' /q)) {
    $macros = where.exe 'macros.txt'
    Get-Content $macros | Where-Object { $_ -match $Pattern }
  }
}
Function B { if (!$Args) { $args = ,95}  DisplayBrightnessConsole @Args }
Remove-Item Alias:C -ea Ignore -Force
New-Alias C Clear-Host -force -scope Global
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
function Get-WmiNamespace {
  [CmdletBinding()]Param ($Namespace='ROOT')
  Get-WmiObject -Namespace $Namespace -Class __NAMESPACE | ForEach-Object {
    ($ns = '{0}\{1}' -f $_.__NAMESPACE,$_.Name)
    Get-WmiNamespace -Namespace $ns
  }
}

function Get-WmiClass {
  [CmdletBinding()]Param($Pattern='^.')
  Get-WmiNamespace | ForEach-Object {
    Get-WmiObject -Namespace $_ -List |
      ForEach-Object { $_.Path.Path }         |
      Where-Object { $_ -match $Pattern }
  } | Sort-Object -Unique
}

Function Get-SpeechSynthesizer {
  [CmdletBinding()]Param(
    [Alias('gettype')][switch]$Type
  )
  If ($SpeechType = Add-Type -AssemblyName System.Speech -passthru) { # | gm
    If ($Type) {
      Write-Verbose "Returning Synthezizer, try:  $SpeechType | gm -static"
      $SpeechType
    } else {
      $SpeechSynthesizer = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
      $SpeechSynthesizer
      If ($SpeechSynthesizer) {
        Write-Verbose "Speaking now..."
        If ($PSBoundParameters.ContainsKey('Verbose')) {
          $SpeechSynthesizer.Speak('Hello World!')
        }
      } else {
        Write-Verbose "No synthesizer"
      }
    }
  }
}
<#  SpeechType
IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
False    True     SRID                                     System.Enum
False    False    SR                                       System.Object

    SpeechType | gm -static
#>

Function Get-MemberType{
  [CmdletBinding()][Alias('IsMember','Member?','MemberP')]
  Param(
    [Parameter(Mandatory)][Object]$InputObject,
    [Alias('Name')][string]$MemberName
  )
  $ChildNames = $MemberName -split '\.'
  $Object = $InputObject;
  Write-Verbose "ChildNames: $ChildNames"
  ForEach ($Name in $ChildNames) {
    Write-Verbose "1-Name: $Name $($Object.GetType())"
    If (!($Member = Get-Member -Name $Name -InputObject $Object -ea Ignore)) {
      Write-Verbose "Returning with no child: $Name"
      return $Null            # nothing there
    }
    Write-Verbose "2-Name: $Name Type: $($Object.GetType()) MemberType $($Member.MemberType)"
    $Object = $Object.$Name
    If ($Member.MemberType -notmatch 'Property') { break }  # Function, etc.
  }
  $Object.GetType()
}

Function Set-StreamColor {
  [CmdletBinding()][Alias('SSC')]Param(
    [string]$StreamName      = 'Error',
    [string]$BackGroundColor = 'DarkRed',
    [string]$ForeGroundColor = 'White'
  )
  If (Get-MemberType $Host "PrivateData.$($StreamName)BackgroundColor") {
    $host.PrivateData."$($StreamName)BackGroundColor" = $BackGroundColor
    $host.PrivateData."$($StreamName)ForeGroundColor" = $ForeGroundColor
    # $host.PrivateData.debugbackgroundcolor   = 'black'
  }
}



Function Get-NewLine { [environment]::NewLine }; new-alias NL Get-NewLine -force
if (! (Get-Command write-log -type Function,cmdlet,alias -ea ignore)) {
  new-alias write-log write-verbose -force -scope Global -ea ignore
}

#(dir C:\Util\*64.???).fullname | Where { $_ -replace '64(?=\.)' | dir -name -ea ignore } | ForEach-Object { New-Alias $($Name -replace '\.exe') $_ -force -Scope Global }
new-alias em       C:\emacs\bin\runemacs.exe                    -force -scope Global -ea ignore
new-alias kp      'C:\Program Files (x86)\KeePass2\KeePass.exe' -force -scope Global -ea ignore
new-alias KeePass 'C:\Program Files (x86)\KeePass2\KeePass.exe' -force -scope Global -ea ignore
new-alias rdir    Remove-Item  -force -scope Global -ea ignore
new-alias cdir    cd           -force -scope Global -ea ignore
new-alias mdir    mkdir        -force -scope Global -ea ignore
new-alias mvdir   move-item    -force -scope Global -ea ignore
new-alias modir   more         -force -scope Global -ea ignore
new-alias moredir more         -force -scope Global -ea ignore
new-alias tdir    Get-Content  -force -scope Global -ea ignore
new-alias typedir Get-Content  -force -scope Global -ea ignore
new-alias ldir    less         -force -scope Global -ea ignore
new-alias lessdir less         -force -scope Global -ea ignore
new-alias l       less         -force -scope Global -ea ignore
new-alias iv 'C:\Program Files\IrfanView\i_view64.exe' -scope Global -force -ea Ignore
<#
.Synopsis
  Start Emacs using server, start server if not running

.Notes
;;  This makes Emacs ignore the "-e (make-frame-visible)"
;;  that it gets passed when started by emacsclientw.
;;
;(add-to-list 'command-switch-alist '("(make-frame-visible)" .
;			     (lambda (s))))
-V, --version           Just print version info and return
-H, --help              Print this usage information message
-nw, -t, --tty          Open a new Emacs frame on the current terminal
-c, --create-frame      Create a new frame instead of trying to
                        use the current Emacs frame
-F ALIST, --frame-parameters=ALIST
                        Set the parameters of a new frame
-e, --eval              Evaluate the FILE arguments as ELisp expressions
-n, --no-wait           Don't wait for the server to return
-q, --quiet             Don't display messages on success
-d DISPLAY, --display=DISPLAY
                        Visit the file in the given display
--parent-id=ID          Open in parent window ID, via XEmbed
-f SERVER, --server-file=SERVER
                        Set filename of the TCP authentication file
-a EDITOR, --alternate-editor=EDITOR
                        Editor to fallback to if the server is not running
                        If EDITOR is the empty string, start Emacs in daemon
                        mode and try connecting again
#>
Function remacs {
  [CmdletBinding(DefaultParameterSetName='Path', SupportsShouldProcess, SupportsTransactions)]
  [Alias('emacs','em','e')]param(
    [Parameter(Position=0, ParameterSetName='Path',
      ValueFromPipeline,ValueFromPipelineByPropertyName)]
      [string[]]$Path=@(),
    [Parameter(Position=0, ParameterSetName='LiteralPath', Mandatory=$true,
      ValueFromPipelineByPropertyName=$true)][Alias('PSPath')][string[]]$LiteralPath,
                [string]$Filter  = '',
                [string]$Include = '',
                [string]$Exclude = '',
    [parameter(ValueFromRemainingArguments=$true)]$Remaining,
    [Alias('H')][switch]$Help    = $False,
    [Alias('V')][switch]$Version = $False,
                [switch]$Test    = $False
  )
  Begin {
    Set-StrictMode -Version Latest
    $Verbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters.Verbose
    If ($PSBoundParameters.ContainsKey('Verbose')) { $PSBoundParameters.Remove('Verbose') }
    $Process       = $True
    $EmacsPath     = "c:\emacs\bin"
    $EmacsClient   = "$EmacsPath\emacsclientw.exe"
    $EmacsCLI      = "$EmacsPath\emacsclient.exe"
    $EmacsServer   = "$EmacsPath\runemacs.exe"
    $ServerOptions = '-n', "--alternate-editor=$EmacsServer"
    Write-Verbose "Property set: $($PSCmdlet.ParameterSetName)"
  }
  Process {
    If ($Help) {
      $Process = $False
      & $EmacsCLI --help
      & $EmacsCLI --version
    } ElseIf ($Version) {
      $Process = $False
      & $EmacsCLI --version
    } ElseIf ($Process) {
      If ($PSBoundParameters.ContainsKey('LiteralPath')) {
        $Path = @($PSBoundParameters.LiteralPath)
      }
      $Files = @(ForEach ($Item in $Path) {
        If ($Item -match '(.*):?(\+\d+(?::\d+)?$)') {
          $Matches[2]
          If ($Matches[1]) {
            $Matches[1].trim(';: ')
          } Else {
            $ForEach.MoveNext()
            $ForEach.Current
          }
        } ElseIf (Test-Path $Item) {
          $Parms  = If ($Filter ) { @{Filter  = $Filter } } Else { @{} }
          $Parms += If ($Exclude) { @{Exclude = $Exclude} } Else { @{} }
          $Parms += If ($Include) { @{Include = $Include} } Else { @{} }
          Get-ChildItem $Item -ea Ignore @Parms
        }
        Else { $Item }
      })
      $Parameters = @() + $Remaining + $Files + $ServerOptions
      Write-Verbose "& $EmacsClient $Parameters"
      If ($Test) {
        & 'echoargs'   @Parameters
      } Else {
        If ($Verbose) {
        & 'echoargs'   @Parameters
        }
        & $EmacsClient @Parameters
      }
    }
  }
  End {}
}

Function Get-Line {
  [CmdletBinding()][Alias('lines','clean')]
  param(
    [Alias('strings','lines')][Parameter(ValueFromPipeline)]
                                   [string[]]$InputObject     = (Get-ClipBoard),
    [Alias('SplitOn')]               [string]$Pattern         = '[\r\n]+',
    [Alias('Ignore')]              [string[]]$Exclude         = @(''),
    [Alias('OnlyIf')]              [string[]]$Include         = @(''),
    [Alias('Blanks','AllowBlanks')]  [switch]$AllowBlankLines = $False
  )
  Begin {
    If ($Exclude) { $Exclude = '(' + ($Exclude -join ')|(') + ')' }
    If ($Include) { $Include = '(' + ($Include -join ')|(') + ')' }
  }
  Process {
    ($InputObject -split $Pattern).trim().where{
      ($_ -or $AllowBlankLines)               -and
      (!$Exclude -or ($_ -notmatch $Exclude)) -and
      (!$Include -or ($_ -match    $Include))
    }
  }
  End {}
}

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
       [string]$Filter  = '',
     [string[]]$Include = '',
     [string[]]$Exclude = ''
     #[switch]${Force},
     #[Parameter(ValueFromPipelineByPropertyName=$true)]
     #[pscredential]
     #[System.Management.Automation.CredentialAttribute()]
     #${Credential})
  )
  Begin   {
    $DateString = Get-Date $Date -Format 'yyyy-MM-dd HH:mm:ss'
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

write-warning "$(Get-Date -Format 'HH:mm:ss') $(LINE)"
$LogFilePath = 'Microsoft.PowerShell_profile-Log.txt'
$UtilityModule = 'PSUtility' # (Join-Path $ProfileDirectory Utility.psm1)
If ($PSVersionTable.PSVersion -gt '7.0.0') {
  . $Home\Documents\WindowsPowerShell\Utility.ps1
} Else {
  $LoadUtilityFile = $True
  If ($True -and (Get-Module $UtilityModule -list -ea ignore)) {
    try {
      Write-Warning "Import Utility Module: $UtilityModule"
      Import-Module $UtilityModule -force
      Write-Warning "$(FLINE) Imported: $UtilityModule COMPLETE"
      $LoadUtilityFile = $False
    } catch {
      Write-Warning "No FLINE: Caught utility module error: $UtilityModule"
    }
  }
}
If ($LoadUtilityFile) {
  try {
    $TryPath = $PSProfileDirectory,$ProfileDirectory,'C:\Bat','.'
    Write-Warning "$(Get-Date -Format 'HH:mm:ss') $(LINE) Try Utility path: $($TryPath -join '; ')"
    If ($Util=(Join-Path $TryPath 'utility.ps1' -ea ignore | Select -First 1)) {
      Write-Warning "Utility: $Util"
      . $Util
      ## Get-Command Write-Log -syntax
      ## Write-Log "$(LINE) Using Write-Log from Utility.ps1"
    }
  } catch { # just ignore and take care of below
    Write-Log "$(LINE) Failed loading Utility.ps1 $Util"
  } finally {}
}
write-warning "$(Get-Date -Format 'HH:mm:ss') $(LINE) ##338"
if ((Get-Command 'Write-Log' -type Function,CmdLet -ea ignore)) {
  Remove-Item alias:write-log -force -ea ignore
} else {
  New-Alias Write-Log Write-Verbose -ea ignore
  Write-Warning "$(LINE) Utility.ps1 not found.  Defined alias for Write-Log"
}

Write-Information "Profile loaded: $($MyInvocation.MyCommand.Path) ##464"
$PSVersionNumber = "$($psversiontable.psversion.major).$($psversiontable.psversion.minor)" -as [double]
Write-Information "$(LINE) PowerShell version PSVersionNumber: [$PSVersionNumber]"
$ForceModuleInstall = [boolean]$ForceModuleInstall
$AllowClobber       = [boolean]$AllowClobber
$Confirm            = [boolean]$Confirm

Write-Warning "$(Get-Date -Format 'HH:mm:ss') $(LINE) Before Set-ProgramAlias"
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
    $WhereFound = If (where.exe $Command /q) {@()} else {@(where.exe $Command)}
    $Path + $WhereFound + $cmdnames
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

$CodeInsiders = 'C:\Program Files\Microsoft VS Code Insiders\bin\code-insiders.cmd'
If (Test-Path $CodeInsiders) {
  new-alias code $CodeInsiders -Scope Global -force
}
# new-alias sense (gcb) -Scope Global -force
# 

$Local:Diff = Get-Command diff.exe -CommandType Application -ea Ignore  | Select -first 1
If ($diff) { 
  Remove-Item Alias:Diff -force -ea ignore
  New-Alias diff $Diff.Definition -scope Global -force -ea Ignore
}
$Local:CoreUtils = Get-Command coreutils.exe -CommandType Application -ea Ignore
If ($CoreUtils) { New-Alias cu $CoreUtils.Definition -scope Global -force }

new-alias v "$(${Env:ProgramFiles})\VideoLan\VLC\vlc.exe" -force -scope global

# netsh advfirewall show allprofiles  state
# netsh advfirewall set allprofiles   state off
# netsh advfirewall set publicprofile state on

# set-netfirewallprofile -All         -Enabled False
# set-netfirewallprofile -name public -Enabled True
# netsh advfirewall firewall delete rule name="TCP Port 6624" protocol=TCP localport=6624
# netsh advfirewall firewall add rule name="TCP Port 6624" dir=in action=allow protocol=TCP localport=6624
# New-NetFirewallRule -DisplayName 'My port' -Profile 'Private' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 6624

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
# NSCP.exe Nagios NSClient++ Network monitor client Network client monitor 
Write-Warning "$(Get-Date -Format 'HH:mm:ss') $(LINE) After Set-ProgramAlias"

# Get-WMIObject Win32_logicaldisk -filter 'drivetype = 3 or drivetype = 4'

$VSCode = Join-Path 'C:\Program Files*\Microsoft VS Code*\bin' Code*.cmd -resolve -ea Ignore | Select -first 1

# 'Thu, 08 Feb 2018 07:47:42 -0800 (PST)' -replace '[^\d]+$' -as [datetime] 13:47:42 -0800 (PST)'
# 'Thu, 08 Feb 2018 07:47:42 -0800 (PST)' -replace '[^\d]+$' -as [datetime] 13:47:42 -0800 (PST)'
#$raw = 'Thu, 08 Feb 2018 13:47:42 -0800 (PST)'
#$pattern = 'ddd, dd MMM yyyy Get-History:mm:ss zzz \(PST)'
#[DateTime]::ParseExact($raw, $pattern, $null)
if ($MyInvocation.HistoryID -eq 1) {
  if (Get-Command Write-Information -type cmdlet,Function -ea ignore) {
    $InformationPreference = 'Continue'
    Remove-Item alias:Write-Information -ea ignore
    $global:informationpreference = $warningpreference
  } else {
    write-warning '$(LINE) Use write-warning for information if Write-Information not available'
    new-alias Write-Information write-warning -force -ea Ignore
  }
}
if ($Quiet -and $global:informationpreference) {
  $informationpreferenceSave = $global:informationpreference
  $global:informationpreference = 'SilentlyContinue'
  $script:informationpreference = 'SilentlyContinue'
  Write-Information "SHOULD NOT WRITE"
}

If ([Environment]::OSVersion.Version -gt [version]'6.1') {
  $Script:ImmersiveShell = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell'
  Set-ItemProperty -path $ImmersiveShell -Name DisableCharmsHint -type DWORD -value 1 -force -ea Ignore
  Set-ItemProperty -path $ImmersiveShell -Name DisableTLCorner   -type DWORD -value 1 -force -ea Ignore
}

# If (Get-ItemProperty 'HKCU:\CONTROL PANEL\DESKTOP' -name WindowArrangementActive -ea Ignore |
#   Select-Object WindowArrangementActive | Format-List | findstr "WindowArrangementActive") {
#   Set-ItemProperty 'HKCU:\CONTROL PANEL\DESKTOP' -name WindowArrangementActive -value 0 -type dword -force
# }
Function Set-PropertyForce {
  [CmdletBinding()]Param(
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
      [string[]]$Path = '',
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
      [string[]]$Name = $Null,
    $Value = $Null,
    [switch]$Force = $False
  )
  Begin {
    $Force = $PSBoundParameters.ContainsKey('Force') -and $Force
  }
  Process {
    If (!($Prop = (Get-ItemProperty -Path $Path -Name $Name -ea Ignore |
      Select $Name))) {
      If (!(Test-Path $Path -ea ignore) -and $Force) {
        Write-Warning "Creating path: $Path"
        MkDir $Path -Force -ea Ignore
      }
      Write-Warning "Set property: $Name"
      Set-ItemProperty -Path $Path -Name $Name -value 1 -Force:$Force -ea Ignore
    }
  }
}
$Script:RegistryConfiguration = @(
  ,@('HKCU:\Test', 'TestingScript', 99, $True)
##  @('HKCU:\CONTROL PANEL\DESKTOP', 'WindowArrangementActive', 0, $True)
## ,@('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', '1', 0, $True)
 # ,@('', '', 0, $True)
 # ,@('', '', 0, $True)
)
ForEach ($Entry in $Script:RegistryConfiguration) {
  $Path, $Name, $Value, $Force = $Entry
  Write-Warning "Set Property: [$Path] [$Name] [$Value] [$Force]"
#  Set-PropertyForce -Path $Path -Name $Name -Value $Value -Force:$Force
}
# If (!(($Current = Get-ItemProperty $Path -name $Name -ea Ignore) -and
#       ($Current.$Value -eq $Value))) {
#   Select-Object WindowArrangementActive | Format-List | findstr "WindowArrangementActive") {
#   # If (!(Test-Path $Path))
#     Set-ItemProperty 'HKCU:\CONTROL PANEL\DESKTOP' -name WindowArrangementActive -value 0 -type dword -force
#   }
# }


# https://onedrive.live.com?invref=b8eb411511e1610e&invscr=90  Free one drive space

Function Get-CurrentIPAddress {(ipconfig) -split "`n" | Where-Object {
  $_ -match 'IPv4' } | ForEach-Object { $_ -replace '^.*\s+' }
}

Function Get-RegKey {
  [Alias('grk','get-reg','get-key','grk','hkey')]
  param(
                              [string[]]$Key,
                                [switch]$Double    = $Null,
                                [switch]$Single    = $Null,
    [Alias('DosOnly','RegOnly')][switch]$CmdOnly   = $Null,
                                [switch]$PSOnly    = $Null,
    [Alias('QO')]               [switch]$QuoteOnly = $Null,
                                [switch]$NoQuote   = $Null,
                                [switch]$Quote     = $Null
  )
  Begin {
    $Keys = New-Object System.Collections.ArrayList
    If ($QuoteOnly) { $Quote = $True }
    If ($Double -or $Single) { $Quote = $True }
  }
  Process {
    If (!$Key) {
      $Key = @(((Get-ClipBoard) -split "`n").trim('\s\\''"').Where{$_ -and $_ -match '^HK'})
    }
    ForEach ($K in $key) {
      $K2 = $K -replace 'HK\w*_(.)\w*_(.)\w*:?','HK$1$2:'
      If (!$CmdOnly) { [Void]$Keys.Add($K2) }
      $K1 = $K2 -replace ':'
      If (!$PSOnly)  { [Void]$Keys.Add($K1) }
      If ($Keys) {
        ForEach ($K3 in $Keys) {
          If ($Quote) {
            If (!$Double) {  "'$K3'"  }
            If (!$Single) { "`"$K3`"" }
          } ElseIf (!$NoQuote -and ($K3 -match '\s')) {
            "'$K3'"
          }
          If (!$QuoteOnly) { $K3 }
        }
      }
    }
  }
  End {}
}

Function Get-WhoAmI { "[$PID]",(whoami),(hostname) + (Get-CurrentIPAddress) -join ' ' }
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

Function Get-DotNetVersion {
  [CmdletBinding()]param(
    [version]$MinimumVersion='0.0.0.0',
    [version]$MaximumVersion='999.9.9.9'
  )
  # $MinimumVersion = $MinimumVersion
  Write-Information '[Information] .NET dotnet versions installed'
  $DotNetKey = @('HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP',
                 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4')
  @(foreach ($key in  $DotNetKey) { Get-ChildItem $key }) |
    Get-ItemProperty -ea ignore |
    Select-Object @{N='Name';E={$_.pspath -replace '.*\\([^\\]+)$','$1'}},version,
      InstallPath,@{N='Path';E={($_.pspath -replace '^[^:]*::') -replace '^HKEY[^\\]*','HKLM:'}} |
      Where-Object { $MaximumVersion -ge $_.Version -and $MinimumVersion -le $_.Version }
}
If ($ShowDotNetVersions) { Get-DotNetVersion }
Write-Warning "$(Get-Date -Format 'HH:mm:ss') $(LINE) After ShowDotNetVersions"
$DefaultConsoleTitle = 'Windows PowerShell'
Function Update-PackageManager {
  If (Test-Administrator) {
    $DefaultConsoleTitle = 'Administrator: Windows PowerShell'
    # https://github.com/PowerShell/PowerShellGet/archive/1.6.0.zip
    try {
      if ((Get-PSVersion) -lt 6.0) {
        If (Get-Package 'Nuget' -ea ignore) {
          write-warning "$(Get-Date -Format 'HH:mm:ss') $(LINE)"
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
        If ($PSBoundParameters['Verbose'] -and $Verbose) { $PSGallery | Format-Table }
      }
    } catch {
      Write-Information "$(LINE) Problem with PSRepository"
    }
  }
}
If ($UpdatePackageManager) { Update-PackageManager }
$PSVersionNumber = "$($psversiontable.psversion.major).$($psversiontable.psversion.minor)" -as [double]
$CurrentWindowTitle = $Host.ui.RawUI.WindowTitle
if ($CurrentWindowTitle -match 'Windows PowerShell([\(\)\s\d]*)$') {
  $Host.ui.RawUI.WindowTitle += " $(Get-WhoAmI) OS:" +
    (Get-WMIObject win32_operatingsystem).version + "PS: $PSVersionNumber"
}

write-warning "$(Get-Date -Format 'HH:mm:ss') $(LINE) Before Show-Module "

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
# [Net.Sockets.TCPClient]::New
# Check TCP connection (New-Object Net.Sockets.TcpClient).Connect("<remote machine>",<port>)
# Check UDP conection  (New-Object Net.Sockets.UdpClient).Connect("<remote machine>",<port>)

Function Test-TCP {
  [CmdletBinding()]Param($ComputerName='www.google.com',$Port=80)
  try {
    (New-Object Net.Sockets.TcpClient).Connect($ComputerName,$Port)
    $True
  } Catch { $False }
}


Function Test-TCPPort {  # check actual IP & Port combination
  [Alias('Test-TCPService','TestTCP','tcp')][CmdLetBinding()]Param(
    [string]$Server='127.0.0.1',
    [Uint16]$Port=135,
    [Alias('Wait','MaxWait')]$TimeOut=3000
  )
  if ($TimeOut -lt 30) { $TimeOut *= 1000 }
  $Failed = $False
  $Succeeded = $True
  try {
    $ErrorActionPreference = 'Continue'
    $tcpclient = new-Object system.Net.Sockets.TcpClient
    $Start = Get-Date
    Function Elapsed { param($Start = $Start) '{0,5:N0}ms' -f ((Get-Date) - $Start).TotalMilliseconds }
    $iar = $tcpclient.BeginConnect($Server, $port, $null, $null) # Create Client
    $wait = $iar.AsyncWaitHandle.WaitOne($TimeOut,$false)         # Set timeout
    if (!$wait) {                                                 # Check if connection is complete
        $Failed = $True
    }  else {
      $tcpclient.EndConnect($iar) | out-Null
      if (!$?) {
        $failed = $true
      }
    }
  } catch {
    $Failed = $True
  } finally {
    if ($tcpclient.Connected) {
      $null = $tcpclient.Close
    }
  }
  !$failed  # Return $true if connection Establish else $False
}


<#
[System.Windows.Forms.Screen]::AllScreens
[System.Windows.Forms.Screen]::PrimaryScreen
# Make nicely formatted simple directory for notes:
Get-ChildItem | Sort-Object LastWriteTime -desc | ForEach-Object { '{0,23} {1,11} {2}' -f $_.lastwritetime,$_.length,$_.name }
#>

Function New-RDPSession {
  [CmdLetBinding()]param(
    [Alias('Remote','Target','Server')]$ComputerName,
    [Alias('ConnectionFile','File','ProfileFile')]$path='c:\bat\good.rdp',
    [int]$Width=2000, [int]$Height=1080,
    [Alias('NoConnectionFile','NoFile','NoPath')][switch]$NoProfileFile,
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$RemArgs,
    [Alias('Assist')][switch]$Control,
    [Alias('Watch')]$Shadow
  )
  $argX = $args
  If (!$Path -or !(Test-Path $Path)) {
    If ($Path) { Write-Warning 'RDP Profile not found: $Path' }
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



# $x = quser; $head = ($x[0] -split '\s{2,}') -replace '\s+',''; $data = $x | ? { $_ } | select -skip 1 | convertfrom-string -PropertyNames $head -delim '\s\s+'
Function Get-WinStaSession {
  [CmdletBinding()]param(
    [Alias('Name')][string]$UserName,
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
    $S = [ordered]@{ ComputerName = $ComputerName };
    $O = [ordered]@{ ComputerName = $ComputerName };
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

Function Set-EnvironmentVariable {
  [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Low')]
  [Alias('Set-Environment','Set-Env','sev','setenv')]Param(
    [string[]]$Variable                          = $Null,
    [string[]]$Value                             = @(),
    [string[]]$Scope                             = 'Local',
    [switch]  $Local                             = $False,
    [switch]  $Process                           = $False,
    [switch]  $User                              = $False,
    [Alias('Computer','System')][switch]$Machine = $False
  )
  Begin {
    $Scope = Switch ($True) {
      { $Local   } { 'Local'   }
      { $Process } { 'Process' }
      { $User    } { 'User'    }
      { $Machine } { 'Machine' }
      Default      { $Scope    }
    }
  }
  Process {
    ForEach ($Var in $Variable) {
      If ($Var -is 'System.Collections.DictionaryEntry') {
        $Var, $Val = $Var.Name, $Var.Value
      } Else {
        If ($Value) { $Val, $Value = $Value }
        If ($Scope) { $Env, $Scope = $Scope }
      }
      If ($Env -in 'Computer','System') { $Env = 'Machine'}
      If ($Var -as [String]) {
        $Val = If ($Val = Get-Variable Val -ea 4 -value) { $Val -as 'string' } Else { '' }
        Write-Verbose "Set environment [$Var=$Val] in [$Env] scope"
        If ($PSCmdlet.ShouldProcess("$Env scope", "Set [$Var=$Val]")) {
          If ($Env -eq 'Local') { Set-Item -Path "Env:$Var" -Value $Val }
          Else { [Environment]::SetEnvironmentVariable($Var,$Val,$Env) }
        }
      }
    }
  }
  End {}
}

Function Get-EnvironmentVariable {
  [CmdletBinding()][Alias('Get-Environment','Get-Env','gev','env')]
  [OutputType([String],[String[]],
    [System.Collections.DictionaryEntry],[System.Collections.DictionaryEntry[]])]
  Param(
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('Key','Name','Path')][string[]]$Variable = $Null,
    [string[]]$Scope                                = 'Local',
    [switch]  $Local                                = $False,
    [switch]  $Process                              = $False,
    [switch]  $User                                 = $False,
    [switch]  $Value                                = $False,
    [Alias('Computer','System')][switch]$Machine    = $False
  )
  Begin {
    $Scope = Switch ($True) {
      { $Local   } { 'Local'   }
      { $Process } { 'Process' }
      { $User    } { 'User'    }
      { $Machine } { 'Machine' }
      DEFAULT      { $Scope    }
    }
  }
  Process {
    ForEach ($Var in $Variable) {
      If ($Var -is 'System.Collections.DictionaryEntry') {
        $Var, $Val = $Var.Name
      } Else {
        If ($Scope) { $Env, $Scope = $Scope }
      }
      If ($Env -in 'Computer','System') { $Env = 'Machine'}
      If ($Var -as [String]) {
        If ($Env -eq 'Local') {
          $Item = Get-Item -Path "Env:$Var"
          If ($Value) { $Item.Value } Else { $Item }
        } Else {
          If ($Null -ne ($Val = [Environment]::GetEnvironmentVariable($Var,$Env))) {
            If ($Value) { $Val }
            Else        { [System.Collections.DictionaryEntry]::New($Var, $Val) }
          }
        }
      }
    }
  }
  End {}
}

Function Get-CommandPath {
  [CmdletBinding()][OutputType([String],[String[]])]param(
    [Alias('Prepend','Before')]   [string[]]$Prefix = '',
    [Alias('Append', 'After' )]   [string[]]$Suffix = '',
                                    [switch]$Unique,
                                    [switch]$Clean,
                                    [switch]$User,
    [Alias('Computer')]             [switch]$Machine,
                                    [switch]$Process,
    [Alias('Length','size','Count')][switch]$Statistics,
    [Alias('Test'  )]               [switch]$Resolve
  )
  $Unique = $Unique -or $Clean
  $Path   = Switch ($True) {
    { [Boolean]$User    } { Get-EnvironmentVariable 'Path' -Value -User    }
    { [Boolean]$Machine } { Get-EnvironmentVariable 'Path' -Value -Machine }
    { [Boolean]$Process } { Get-EnvironmentVariable 'Path' -Value -Process }
    Default               { $Env:Path                                      }
  }
  $LengthPrior  = $Path.Length
  $Path         = $Path -split ';' | Where-Object Length
  $CountPrior   = $Path.Count
  $Path         = $Prefix + $Path + $Suffix | Where-Object Length
  If ($Unique)  { $Path = $Path | Select-Object -Unique:$Unique }
  If ($Resolve) { $Path = Resolve-Path $Path -ea Ignore  }
  $Joined = $Path -join ';'
  If ($Statistics) {
    $LengthAfter = $Joined.Length
    $CountAfter  = $Path.Count
    Write-Warning "Prior Length: $LengthPrior  Count:$CountPrior"
    Write-Warning "After Length: $LengthAfter  Count:$CountAfter"
  }
  If ($Clean)   { $Path = $Joined }
  $Path
}

#################################################################
$InformationPreference = 'continue'
Write-Information "$(LINE) InformationPreference: $InformationPreference"
Write-Information "$(LINE) Test hex format: $("{0:X}" -f -2068774911)"
# "{0:X}" -f -2068774911
Function Get-DriveType {
  [CmdletBinding()][Alias('Get-DriveTypeName')]
  [Alias('DriveTypeName','DriveType','DriveCode')]Param($Type)
  $DriveTypes = [Ordered]@{
    0 = 'UNKNOWN'   # Type cannot be determined.
    1 = 'NOROOTDIR' # Root path is invalid, e.g., no volume mounted at specified path
    2 = 'REMOVABLE' # Removable media       e.g., floppy drive, thumb or flash card reader
    3 = 'FIXED'     # Fixed media           e.g., hard disk drive or SSD
    4 = 'REMOTE'    # Remote network drive
    5 = 'CDROM'     # CDROM drive
    6 = 'RAMDISK'   # RAM disk
  }
  # $a
  If     (!$PSBoundParameters.ContainsKey('Type')) { $DriveTypes        }
  ElseIf ($DriveTypes.Contains($Type))             { $DriveTypes[$Type] }
  Else                                             { 'INVALID'          }
}

Function Get-DriveType {
  [CmdletBinding()][Alias('Get-DriveTypeName')]
  [Alias('DriveTypeName','Type')]
  Param(
    [UInt16[]]$Type=@(0..6)
  )
  Switch ($Type) {
    0       { 'UNKNOWN'   } # Type cannot be determined.
    1       { 'NOROOTDIR' } # Root path is invalid, e.g., no volume mounted at specified path
    2       { 'REMOVABLE' } # Removable media       e.g., floppy drive, thumb or flash card reader
    3       { 'FIXED'     } # Fixed media           e.g., hard disk drive or SSD
    4       { 'REMOTE'    } # Remote network drive
    5       { 'CDROM'     } # CDROM drive
    6       { 'RAMDISK'   } # RAM disk
    Default { 'INVALID'   }
  }
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

If ((Get-Command rg.exe -type application -ea Ignore) -and
    (Test-Path "$ProfileDirectory\config\.ripgreprc")) {
  $ENV:RIPGREP_CONFIG_PATH = "$ProfileDirectory\config\.ripgreprc"
}

Function Get-Free {
  [CmdletBinding(DefaultParameterSetName='Name')]Param(
    [String[]]$Name='*',
    [String]$Scope = 'Local',
    [String]$Units = 'GB',
    [switch]$UseTransaction
  )
  If ($Name.Count -eq 1 -and $Name -match '^[GMKBTEXP][a-z]*B') {
    $Units, $Name = $Name, '*'
    $PSBoundParameters.Remove('Name')
    Write-Verbose "Name=[$Name] $Units=$Units"
  }
  $Units, $Divisor, $Precision = Switch -regex ($Units) {
    '^G'    { 'GB'    ; 1GB,     1; break }
    '^M'    { 'MB'    ; 1MB,     1; break }
    '^K'    { 'KB'    ; 1KB,     1; break }
    '^B'    { 'Bytes' ; 1  ,     0; break }
    '^T'    { 'TB'    ; 1TB,     1; break }
    '^P'    { 'PB'    ; 1PB,     1; break }
    '^[EX]' { 'EB'    ; 1PB*1KB, 1; break }
    Default { 'GB'    , 1GB,     1; break }
  }
  If ($PSBoundParameters.ContainsKey('Units')) { $PSBoundParameters.Remove('Units')}
  If ($PSBoundParameters.ContainsKey('Name') -and $PSBoundParameters.'Name' -notmatch '^\*?$')  {
    $Name = $Name | ForEach-Object {
      If (Test-Path $_ -ea Ignore) { (Resolve-Path $Name).Drive } Else { $Name }
    }
    $PSBoundParameters.Name = $Name -replace '(:.*)'
  }
  $PSBoundParameters.PSProvider = 'FileSystem'
  $PSDrives = Get-PSDrive @PSBoundParameters
  $MaxUsed, $MaxFree = get-psdrive | measure -max Used,Free | Select Maximum | ForEach Maximum
  $WidthUsed = [math]::floor([math]::Log10($MaxUsed/$Divisor)+1) + 2 + 1 #7;
  $WidthFree = [math]::floor([math]::Log10($MaxUsed/$Divisor)+1) + 2 + 1 #7;
  $PSDrives | Where-Object Used -ne '' | ForEach-Object {
    # Write-Verbose "{0,$WidthUsed:N$Precision}"
    # Write-Verbose "{0,$WidthFree:N$Precision}"
    [PSCustomObject]@{
      "Used$Units"    = "{0,$($WidthUsed):N$Precision}" -f ($_.Used / $Divisor)
      "Free$Units"    = "{0,$($WidthFree):N$Precision}" -f ($_.Free / $Divisor)
      Root            = $_.Root   # '{0,4}' -f  $_.Root
      CurrentLocation = $_.CurrentLocation
    }
  }
}


#  Get-PSVolume
# (Get-WMIObject win32_volume ) | Where-Object {$_.DriveLetter -match '[A-Z]:'} |
#  ForEach-Object { "{0:2} {0:2} {0:9} {S:9} "-f $_.DriveLetter, $_.DriveType, (Get-DriveType $_.DriveType), $_.Label, ($_.Freespace / 1GB)}
#  # % {"$($_.DriveLetter) $($_.DriveType) $(Get-DriveType $_.DriveType) $($_.Label) $($_.Freespace / 1GB)GB"}
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
  write-verbose "Full: $([boolean]$fullname)"
  [appdomain]::CurrentDomain.GetAssemblies() | Where-Object {
    $_.fullname -match $inc -and $_.fullname -notmatch $Exc
}
    #-and ($_.IsDynamic -or ($_.GetExportedTypes()))
  }# | ForEach-Object {
   # if ($fullname) {
   #   $_ | Select-Object FullName
   # } else {
   #   $_ | Select-Object GlobalAssemblyCache,IsDynamic,ImageRuntimeversion,Fullname,Location
   # }
   #}
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
  param(
    [String[]]$Include = @(),
    [String[]]$Exclude = @(),
    [switch]$Like
  )
  # $Acc = [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::get
  ForEach ($key in ([psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::get).Keys) {
    $Included = !$Include
    $Excluded = [Boolean]$Exclude
    ForEach ($Pattern in $Include) {
      If ($Key -match $Pattern) {
        $Included = $True
        Break
      }
    }
    ForEach ($Pattern in $Exclude) {
      If ($Key -match $Pattern) {
        $Excluded = $True
        Break
      }
    }
    if ($key -notmatch $Include -or $Excluded) {continue}
    [pscustomobject]@{
      Accelerator = $key
      # Definition  = $Acc.$key
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
  If ($PSBoundParameters.ContainsKey('ShowID')) {
    $ShowID = [boolean]$ShowID
    $PSBoundParameters.Remove('ShowID')
  }
  $Pattern = If ($PSBoundParameters.ContainsKey('Pattern')) {
    $Pattern = $PSBoundParameters.Pattern
    $PSBoundParameters.Remove('Pattern')
  } Else {
    '\S'
  }
  @(get-history @PSBoundParameters).commandline -match $Pattern
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
        If ($IncludeID) {
        } Else {
          $H = Select-Object ID,CommandLine, StartExecutionTime,EndExecutionTime,ExcutionStatus,Status
        } # 9/10/2019 9:48:41 AM
      }
      #if ($PSBoundParameters['Verbose'] -and $Verbose) {
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

Function Get-Syntax {
  Param(
    [Alias('CommandName')][string[]]$Name='Get-Command'
  )
  ForEach ($Command in $Name) {
    If (($Cmd = Get-Alias $Command -ea Ignore) -and ($Cmd = $Cmd.definition)) { $Command = $Cmd }
    If ($Command) {Get-Command $Command -syntax}
  }
}   # syntax get-command
New-Alias Syn Get-Syntax -force -Desc "Set in Profile"

Function Get-FullHelp { Get-Help -Full @Args }
'hf','full','fh','fhelp','helpf' | ForEach-Object { new-alias $_ get-fullhelp -force -ea continue }
Write-Information "$(LINE) $home"
Write-Information "$(LINE) Try: import-module -prefix cx Pscx"
Write-Information "$(LINE) Try: import-module -prefix cb PowerShellCookbook"
# new-alias npdf 'C:\Program Files (x86)\Nitro\Reader 3\NitroPDFReader.exe' -force -scope Global
# new-alias npdf 'C:\Program Files (x86)\Nitro\Reader 3\NitroPDFReader.exe' -force -scope Global
If (Get-Alias npdf -ea Ignore) { Remove-Item Alias:npdf -ea Ignore }


New-Alias pdf2text 'C:\Program Files\MiKTeX\miktex\bin\x64\miktex-pdftotext.exe' -force -scope Global
New-Alias pandoc   'C:\Users\Herb\AppData\Local\Pandoc\pandoc.exe'               -force -scope Global
<#
.Synopsis sbcl runs the Steele-Bank Common Lisp REPL
.Notes
  Common runtime options:
  --help                     Print this message and exit.
  --version                  Print version information and exit.
  --core <filename>          Use the specified core file instead of the default.
  --dynamic-space-size <MiB> Size of reserved dynamic space in megabytes.
  --control-stack-size <MiB> Size of reserved control stack in megabytes.

Common toplevel options:
  --sysinit <filename>       System-wide init-file to use instead of default.
  --userinit <filename>      Per-user init-file to use instead of default.
  --no-sysinit               Inhibit processing of any system-wide init-file.
  --no-userinit              Inhibit processing of any per-user init-file.
  --disable-debugger         Invoke sb-ext:disable-debugger.
  --noprint                  Run a Read-Eval Loop without printing results.
  --script [<filename>]      Skip #! line, disable debugger, avoid verbosity.
  --quit                     Exit with code 0 after option processing.
  --non-interactive          Sets both --quit and --disable-debugger.
Common toplevel options that are processed in order:
  --eval <form>              Form to eval when processing this option.
  --load <filename>          File to load when processing this option.
C:\build\SBCLisp\sbcl.exe --core (resolve-path sbcl.core) --dynamic-space-size 10000 --load quicklisp.lisp

Mastering the Vim Language
  Vim  as a language  Ben McCormick
  carbon5 definitive guide text objects
  Emacs VIM Atom can't replace Vim composability
  Use VIm.com stop configuration madness mastering motins and operators
  StackOverFlow You problem with Vim is you don't grok Vi
  Relative Number

  Surround
  Commentary
  ReplaceWithRegister
  TitleCase
  Sort-Motion
  System-Copy

  Indent
  ENtire
  line
  ruby doc

  Wiki custom test objects

  MikTex Pandoc
  fast.com
  google tr
  wikipedia
  emoj
  youtube
  wego   weather
  whereami
  wordnet?  american heritage
  hacker typer

  Ace Windows
  lorem ipsum
  Swiper   ctrl-s swiper    AceJump, ivy Avy Hydra
  help ido ->
  Ace Jump Mode (Avy) Ce la vie Emacs.com

  use-package
    :init
    :config


#>
Function sbcl {
  [CmdletBinding(DefaultParameterSetName='Path')]
  Param(
    [Alias('LoadFiles','Files')][Parameter(ParameterSetName='Path',Position=0,
      ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [string[]]$Path                               = @(),
    [Parameter(ParameterSetName='LiteralPath', Mandatory,
      ValueFromPipeLine, ValueFromPipelineByPropertyName)]
    [Alias('PSPath')][string[]]$LiteralPath       = @(),
    [string]$SBCL                                 = 'C:\build\SBCLisp\sbcl.exe',
    [string]$Core                                 = 'C:\build\SBCLisp\sbcl.core',
    [Int32]$DynamicSpaceSize                      = 10000,
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$Arguments                          = @(),
    [switch]$help                                 = $False,
    [switch]$version                              = $False,
    [switch]$nosysinit                            = $False,
    [switch]$nouserinit                           = $False,
    [Alias('nodebugger')][switch]$disabledebugger = $False,
    [switch]$noprint                              = $False,
    [switch]$quit                                 = $False,
    [switch]$noninteractive                       = $False
  )
  Begin {
    Write-Verbose "Arguments: $($Arguments -join ' ')"
    $Extra = @(Switch ($True) {
      { [boolean]$help            } { '--help'             }
      { [boolean]$version         } { '--version'          }
      { [boolean]$nosysinit       } { '--no-sysinit'       }
      { [boolean]$nouserinit      } { '--no-userinit'      }
      { [boolean]$disabledebugger } { '--disable-debugger' }
      { [boolean]$noprint         } { '--noprint'          }
      { [boolean]$quit            } { '--quit'             }
      { [boolean]$noninteractive  } { '--non-interactive'  }
    })
    $Core = If ($C = Resolve-Path $Core) {
      $C.Path
    } ElseIf ($C = Join-Path '.','C:\build\SBCLisp' $Core -ea Ignore -resolve) {
      $C
    } ElseIf ($C = Join-Path (Split-Path $SBCL) 'sbcl.core' -ea Ignore -resolve) {
      $C
    } Else {
      $Core
    }
    $CoreParam = @('--core', ($Core -replace '\\', '/'))
    $Extra2 = @(Switch ($True) {
      { [boolean]$DynamicSpaceSize } { '--dynamic-space-size', $DynamicSpaceSize }
      { [boolean]$controlstacksize } { '--control-stack-size', $controlstacksize }
      { [boolean]$sysinit          } { '--sysinit',            $sysinit          }
      { [boolean]$userinit         } { '--userinit',           $userinit         }
      { [boolean]$script           } { '--script',             $script           }
      { [boolean]$eval             } { '--eval',               $eval             }
      { [boolean]$load             } { '--load',               $load             }
    })
    $Path = @(If ($Path) { $Path = '--load', $Load } Else { @() })
    $Parameters = @(ForEach ($A in $Arguments) {
      If ($A -match '^[-/][^-]' ) {
        $A -replace '^[-/]+', '--'
      } Else { $A }
    })
    # --core (resolve-path sbcl.core) --dynamic-space-size 10000 --load quicklisp.lisp
  }
  Process {
    $Parameters = $CoreParam + $Path + $Parameters + $Extra + $Extra2
    ForEach ($parm in 'Core','DynamicSpaceSize','load','literalpath','path') {
      If ($PSBoundParameters.ContainsKey[$parm]) { $Null = $PSBoundParameters.Remove[$parm] }
    }
    $earg = 'C:\Program Files\WindowsPowerShell\Modules\Pscx\3.2.1.0\Apps\EchoArgs.exe'
    Write-Verbose "EArg $($Parameters.getType()): & $EArg $($Parameters -join ' ')"
    Write-Verbose "SBCL $($Parameters.getType()): & $SBCL $($Parameters -join ' ')"
    & $earg @Parameters
    & $SBCL @Parameters
  }
  End {} #-force -scope Global
}

Function npdf {
  [CmdletBinding(DefaultParameterSetName='Path')]
  Param(
    [Parameter(ParameterSetName='Path',Position=0,
      ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [string[]]$Path=@(''),
    [Parameter(ParameterSetName='LiteralPath', Mandatory,
      ValueFromPipeLine, ValueFromPipelineByPropertyName)]
    [Alias('PSPath')][string[]]$LiteralPath=@(),
    [Parameter(ValueFromRemainingArguments)][string[]]$args
  )
  Begin {
    $NitroPDFReader = 'C:\Program Files (x86)\Nitro\Reader 3\NitroPDFReader.exe'
  }
  Process {
    $Names = If ($Path) { $Path } ElseIf ($LiteralPath) { $LiteralPath }
    ForEach ($Name in $Names) {
      If ($N = Resolve-Path $Name -ea Ignore) {
        Write-Verbose "Open Nitro with file [$($N.Path)]"
        & $NitroPDFReader $N.Path }
      Else {
        Write-Warning "File [$Name] not found"
      }
    }
  }
  End {} #-force -scope Global
}


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
      $_ -replace '^(\d\d/\d\d/\d{4})\s+', "$(Get-Date $Matches[1] -Format 'yyyy-MM-dd') "
    } else { $_ }
  }
}

function e {
  [cmdletbinding()]param(
    [Parameter(valuefromremainingarguments)]$args)
  $args = ($args -split '\W+').trim() | ? { $_ -and $_ -notmatch '^-?verbo' } | % { Write-verbose "[$_]"; $_ };
  write-verbose "es $args" ;
  es @args
}
If (Test-Path ($CCL = 'C:\Users\Herb\downloads\ccl\wx86cl64.exe') -ea Ignore) {
  New-Alias ccl $CCL -Force -Scope Global -ea Ignore
}

<#
.Notes
/f or /force Launch unconditionally, skipping any warning dialogs. This has the same effect as #SingleInstance Off. Yes
/r or /restart Indicate that the script is being restarted (this is also used by the Reload command, internally). Yes
/ErrorStdOut Send syntax errors that prevent a script from launching to stderr rather than displaying a dialog. See #ErrorStdOut for details. This can be combined with /iLib to validate the script without running it. Yes
/Debug [v1.0.90+]: Connect to a debugging client. For more details, see Interactive Debugging. No
/CPn [v1.0.90+]: Overrides the default codepage used to read script files. For more details, see Script File Codepage. No
/iLib "OutFile"
[v1.0.47+]: AutoHotkey loads the script but does not run it. For each script file which is auto-included via the library mechanism, two lines are written to the file specified by OutFile.
These lines are written in the following format,
where LibDir is the full path of the Lib folder and LibFile is the filename of the library:
#Include LibDir\
#IncludeAgain LibDir\LibFile.ahk
S???
If the output file exists, it is overwritten. OutFile can be * to write the output to stdout.
If the script contains syntax errors, the output file may be empty.
The process exit code can be used to detect this condition; if there is a syntax error, the exit code is 2.
The /ErrorStdOut switch can be used to suppress or capture the error message.
#>
Function ahk {
  [CmdletBinding(DefaultParameterSetName='Path', SupportsShouldProcess)]
  [Alias('a','autohotkey')]
  param(
    [Parameter(Position=0, ParameterSetName='Path',
      ValueFromPipeline,ValueFromPipelineByPropertyName)]
      [Alias('ScriptFile','FileName')][string[]]$Path=@('c:\bat\ahk.ahk'),
    [Parameter(Position=0, ParameterSetName='LiteralPath', Mandatory=$true,
      ValueFromPipelineByPropertyName=$true)][Alias('PSPath')][string[]]$LiteralPath,
    [parameter(ValueFromRemainingArguments=$true)]$Parameters,
    [Alias('h')]            [switch]$Help        = $Null,
    [Alias('cpage')]        [Uint16]$CodePage    = $Null,
    [Alias('v2')]           [switch]$Version2    = $False,
    [Alias('StdOut')]       [switch]$ErrorStdOut = $False,
    [Alias('dbg','debu')]   [switch]$Debugging   = $False,
    [Alias('nr','NoReload')][switch]$NoRestart   = $False
  )
  Begin {
    Set-StrictMode -Version Latest
    $Verbose   = $PSBoundParameters.ContainsKey('Verbose') -and
                 $PSBoundParameters.Verbose
    $Null      = $PSBoundParameters.Remove('Verbose')
    Write-Verbose "ParameterSet: $($PSCmdlet.ParameterSetName)"
    $AHKPath   = If ($Version2)      { 'C:\util\AutoHotKey2'  }
                 Else                { 'C:\util\AutoHotKey'   }
    $AHK       = Join-Path $AHKPath 'AutoHotKey.exe'
    $AHKHelp   = Join-Path $AHKPath 'AutoHotKey.chm'
    $Switches  = @(If ($CodePage)    { "/CP$CodePage" })
    $Switches += @(If (!$NoRestart)  { '/r'           })
    $Switches += @(If ($ErrorStdOut) { '/ErrorStdOut' })
    $Switches += @(If ($Debugging)   { '/Debug'       })
    If ($Help) { & $AHKHelp }
    $EA  = @{ ErrorAction = 'Ignore'      }
    $App = @{ CommandType = 'Application' }
    $Ext = '.ahk'
  }
  Process {
    If ($Help) { Return }
    [string[]]$ArgX = @(If ($Parameters) { $Parameters })
    write-verbose "$AHK [$($Path -join '] [')] Switches: [$($Switches -join '], [')] ArgX $($ArgX.count): [$($ArgX -join '], [')]"
    If (!($AHK -and (Test-Path $AHK))) { 
      Write-Warning "$(FLINE) AHK not present at: $AHK"
    } Else {
      $Path | ForEach-Object {
        $P = $_.clone()
        $S = @()
        $ResolveBare = Get-Command -name "$P$Ext" @EA @App |
                       Get-Property | ? Name -eq 'Path' | % Value
        Write-Verbose "Path: $P Resolve: [$Path] [$($Path.GetType())]"
        $ResolveWith = Get-Command -name "$P$Ext" @EA @App |
                       Get-Property | ? Name -eq 'Path' | % Value
        Write-Verbose "Path: $P Resolve: [$Path] [$($Path.GetType())]"
        $Script = @(Switch ($True) {
          {[boolean]($S = @(Resolve-Path $P @EA)) -and $S.count} { Get-ScriptPath $S 1; break }
          {[boolean]($ResolveBare)             }                { $ResolveBare; break }
          {[boolean]($S = @(Resolve-Path "$P$Ext" @EA      | Select -First 1)) } { Get-ScriptPath $S 3; break }
          {[boolean]($ResolveWith)             }                { $ResolveWith; break }
          Default                                             { $P                  }
        })
        Write-Verbose "Script: $Script"
        $Script | % {
         If (Test-Path $_) { 
          EchoArgs @Switches $_ @ArgX
          & $AHK   @Switches $_ @ArgX
         } Else {
          Write-Warning "$(FLINE) Script not present at: $_"
         }
        }
      }
    }
  }
}

<#
    Function Get-ScriptPath {
      [CmdletBinding(DefaultParameterSetName='Path')]
      param(
        [Parameter(Position=0, ParameterSetName='Path', ValueFromPipelineByPropertyName)]
        [String[]]$Path = '',
        [Alias('PSPath')]
        [Parameter(Position=0, ParameterSetName='LiteralPath', ValueFromPipeLine)]
        [string[]]$LiteralPath = '',
        [Parameter(Position=0, ParameterSetName='String', ValueFromPipeline)]
        [string[]]$String = '',
        [Parameter(Position=1)]$Index = 0
      )
      $InputObject = Switch ($PSCmdlet.ParameterSetName) {
        'Path'        { $Path        }
        'LiteralPath' { $LiteralPath }
        'String'      { $String      }
      }
      ForEach ($Item in $InputObject) {
        write-verbose "Item $Index [$Item]";
        If (!$Item) { Continue }
        If (!(Test-Path $Item)) {
          Write-Warning "Script not found: [$Item]"
        } Else {
          If ($Script = Resolve-Path $Item -ea Ignore) {
            $Script
          }
        }
      }
    }

  [
                [string]$Filter  = '',
                [string]$Include = '',
                [string]$Exclude = '',
    [parameter(ValueFromRemainingArguments=$true)]$Remaining,
    [Alias('H')][switch]$Help    = $False,
    [Alias('V')][switch]$Version = $False,
                [switch]$Test    = $False
  )
  Begin {
    Set-StrictMode -Version Latest
    $Verbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters.Verbose
    If ($PSBoundParameters.ContainsKey('Verbose')) { $PSBoundParameters.Remove('Verbose') }
    $Process       = $True
    $EmacsPath     = "c:\emacs\bin"
    $EmacsClient   = "$EmacsPath\emacsclientw.exe"
    $EmacsCLI      = "$EmacsPath\emacsclient.exe"
    $EmacsServer   = "$EmacsPath\runemacs.exe"
    $ServerOptions = '-n', "--alternate-editor=$EmacsServer"
    Write-Verbose "Property set: $($PSCmdlet.ParameterSetName)"
  }
  Process {
    If ($Help) {
      $Process = $False
      & $EmacsCLI --help
      & $EmacsCLI --version
    } ElseIf ($Version) {
      $Process = $False
      & $EmacsCLI --version
    } ElseIf ($Process) {
      If ($PSBoundParameters.ContainsKey('LiteralPath')) {
        $Path = @($PSBoundParameters.LiteralPath)
      }
      $Files = @(ForEach ($Item in $Path) {
        If ($Item -match '(.*):?(\+\d+(?::\d+)?$)') {
          $Matches[2]
          If ($Matches[1]) {
            $Matches[1].trim(';: ')
          } Else {
            $ForEach.MoveNext()
            $ForEach.Current
          }
        } ElseIf (Test-Path $Item) {
          $Parms = @{}
          $Parms += If ($Filter)  { @{ Filter  = $Filter  }} Else { @{} }
          $Parms += If ($Exclude) { @{ Exclude = $Exclude }} Else { @{} }
          $Parms += If ($Include) { @{ Include = $Include }} Else { @{} }
          Get-ChildItem $Item -ea Ignore @Parms
        }
        Else { $Item }
      })
      $Parameters = @() + $Remaining + $Files + $ServerOptions
      Write-Verbose "& $EmacsClient $Parameters"
      If ($Test) {
        & 'echoargs'   @Parameters
      } Else {
        If ($Verbose) {
        & 'echoargs'   @Parameters
        }
        & $EmacsClient @Parameters
      }
    }
  }
  End { }
}
#>
Function d    { cmd /c dir @args}
Function dw   { get-childitem $args -force       | sort-object lastwritetime }
Function dfw  { get-childitem $args -force -file | sort-object lastwritetime }
Function ddw  { get-childitem $args -force -dir  | sort-object lastwritetime }
Function df   { Get-ChildItem @args -force -file      }
Function da   { Get-ChildItem @args -force            }
Function dfs  { Get-ChildItem @args -force -file -rec }
Function dd   { Get-ChildItem @args -force -dir       }
Function dds  { Get-ChildItem @args -force -dir  -rec }
Function ddb  { Get-ChildItem @args -force -dir       | ForEach-Object { "$($_.FullName)" }}
Function db   { Get-ChildItem @args -force            | ForEach-Object { "$($_.FullName)" }}
Function dsb  { Get-ChildItem @args -force       -rec | ForEach-Object { "$($_.FullName)" }}
Function dfsb { Get-ChildItem @args -force -file -rec | ForEach-Object { "$($_.FullName)" }}
Function dod  { dd  @args | Sort-Object lastwritetime }
Function dfod { df  @args | Sort-Object lastwritetime }
Function ddod { dd  @args | Sort-Object lastwritetime }
Function dfp  { d /a-@args d /b  | ForEach-Object {Get-ChildItem "$_"} }
Function dl   { Get-ChildItem @args -force -attr ReparsePoint }
new-alias dj dl -force -scope Global
new-alias w  where.exe -force
new-alias wh where.exe -force
new-alias wi where.exe -force
If (Test-Path 'C:\ProgramData\Local\Julia\bin\julia.exe') {
  new-alias julia 'C:\ProgramData\Local\Julia\bin\julia.exe' -force -scope global
}
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
Write-Information "$(LINE) Create ic file: $ICFile"
set-content  $ICFile '. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))'
set-alias ic $ICFile -force -scope global -ea Ignore
# get-uptime;Get-WURebootStatus;Is-RebootPending?;Get-Uptime;PSCx\get-uptime;boottime.cmd;uptime.cmd
#
Function Get-BootTime { (Get-CimInstance win32_operatingsystem).lastbootuptime }
try {
  Write-Information "$(LINE) Boot Time: $(Get-Date ((Get-CimInstance win32_operatingsystem).lastbootuptime) -Format 's')"
} catch {
  Write-Warning     "$(LINE) CIM call to get boot time failed"
}
## Function ul {  $(if ($args) { $args } Else { ul ((gcb)}) -split "`n") }
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
Write-Information "$(LINE) set Prompt Function"
try {
  if (!$global:PromptStack) {
    #if ($global:PromptStack) -ne )
    [string[]]$global:PromptStack +=   (Get-Command prompt).ScriptBlock
  }
} catch {
  [string[]]$global:PromptStack  = @((Get-Command prompt).ScriptBlock)
}
Write-Information "$(LINE) Pushed previous prompt onto `$PromptStack: $($PromptStack.count) entries"
Write-Information "$(LINE) prompt='PS $PWD $('>' * $nestedPromptLevel + '>')'"
# Write-Information "$(LINE) prompt='PS $($executionContext.SessionState.Path.CurrentLocation) $('>' * $nestedPromptLevel + '>')'"
#Function Global:prompt { "PS '$($executionContext.SessionState.Path.CurrentLocation)' $('>.' * $nestedPromptLevel + '>') "}
Function Global:prompt {
  If (!(Test-Path Variable:Global:MaxPromptLength -ea ignore 2>$Null)) { $MaxPrompt = 45 }
  $loc = $PWD                                             # (Get-Location).ProviderPath # -replace '^[^:]*::'
  $Sig = " |>$('>' * $nestedPromptLevel)"                 # Looks like:   <# C:\ #>
  if (Test-Path Variable:Global:MaxPromptLength) {
    $LocLen = $Loc.length; $SigLen = $Sig.Length
    $Length = $LocLen + $SigLen
    $Excess = $Length - $Global:MaxPromptLength
    If ($Excess -gt 0) {
      $Excess = [Math]::Min($Excess, $LocLen)
    }
  }
  write-host -nonewline "'$Loc'$Sig" -fore Cyan -back DarkGray
  ' '                                    # Return a normal 'space' to PS to suppress PS adding it's own prompt
}

If (Test-Path 'C:\Program Files\VLC\vlc.exe' -ea Ignore) { new-alias v 'C:\Program Files (x86)\VLC\vlc.exe' -force -scope Global }

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
Function GalDef {
  Param([string[]]$Definition,[string[]]$Exclude,[string]$Scope)
  Get-Alias @PSBoundParameters
}
New-Alias ts Test-Script -Force -scope Global
Function Test-Clipboard {
  [CmdletBinding()][Alias('tcb','gcbt','tgcb')]Param()
  Get-Clipboard | Test-Script
}
Function Get-HistoryCount {
  [CmdletBinding()][Alias('hcount','hc')]param([int]$Count)
  Get-History -count $Count
}
# }
write-warning "$(Get-Date -Format 'HH:mm:ss') $(LINE) Before Go"
##  TODO:  Set-LocationEnvironment, Set-LocationPath
## (dir ENV:*) |  ? value -match '\\'
Function Get-UserFolder {
  [CmdletBinding()][Alias('guf','gf')]param(
    [Alias('Folder', 'FolderName', 'Directory', 'DirectoryName','Path','PSPath')]
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [string[]]$Name='*',
    [switch]$Regex
  )
  Begin {
    $Key =
      'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
    $Folders = @()
    $RegistryFolders =
      (Get-ItemProperty $Key -name * -ea Ignore).psobject.get_properties() |
        Where-Object Name -notlike 'PS*' | ForEach {
          [PSCustomObject]@{ $_.Name = $_.Value }
          If ($_.Name -eq '{374DE290-123F-4565-9164-39C4925E467B}') {
            [PSCustomObject]@{ Downloads = $_.Value }
          }
        }
  }
  Process {
    $Folders += ForEach ($Folder in $Name) {
      $Folder = $Folder -replace '^Dow.*', '{374DE290-123F-4565-9164-39C4925E467B}'
      $Folder = $Folder -replace '^Doc.*',  'Personal'
      $Folder = $Folder -replace '^(Pict|Vid|Mus).*$', 'My $1'
      $Folder = $Folder -replace '^(AppData)$', 'Local $1'
      Write-Verbose "Folder: Folder pattern: [$Folder]"
      If ($Regex -and ($F = $RegistryFolders | Where Name -match $Folder)) {
        Write-Verbose "Regex: User folders: [$($F.Name)]"
        $F
      } ElseIf ($F = Get-ItemProperty $Key -name $Folder -ea Ignore) {
        $F.psobject.get_properties() | Where-Object Name -notlike 'PS*'
      } Else {
        Write-Warning "User folder: [$Folder] not found"
      }
    }
  }
  End {
    $Folders | Select -unique Name,@{N='PSPath';E={$_.Value}}
  }
}

Function Set-LocationUserFolder {
  [CmdletBinding()][Alias('cdu','cdf','cduf')]
  Param(
    [Alias('Folder', 'FolderName', 'Directory', 'DirectoryName','Path','PSPath')]
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [string[]]$Name='*',
    [switch]$PassThru
  )
  If ($PSBoundParameters.ContainsKey('PassThru')) {
  }
  ForEach ($Folder in $Name) {
    If ($F = Get-UserFolder $Folder) { Set-Location $F.Folder }
  }
}

try {
  $ECSTraining = "\Training"
  $SearchPath  = 'D:\',"$Home\Downloads", 'C:\',"$Home\Downloads","S:$ECSTraining","T:$ECSTraining"
  $Script:Books = Join-Path $SearchPath 'Books' -ea ignore -resolve | Select-Object -First 1
} catch {
  $Script:Books = $PSProfileDirectory
}  # just ignore
$goHash = [ordered]@{
  book       = $books
  books      = $books
  build      = 'C:\Build'
  dev        = 'c:\dev'
  doc        = "$home\documents"
  docs       = "$home\documents"
  down       = "$home\downloads"
  download   = "$home\downloads"
  downloads  = "$home\downloads"
  esb        = 'c:\esb'
  Home       = $Home
  Buile      = 'C:\Build'
  P86        = ${ENV:ProgramFiles(x86)}
  PF86       = ${ENV:ProgramFiles(x86)}
  x86        = ${ENV:ProgramFiles(x86)}
  Prog       = ${ENV:ProgramFiles}
  PF         = ${ENV:ProgramFiles}
  PD         = ${ENV:ProgramData}
  power      = "$books\PowerShell"
  PowerShell = "$Books\PowerShell"
  pro        = $PSProfileDirectory
  prof       = $PSProfileDirectory
  profile    = $ProfileDirectory
  ps         = "$books\PowerShell"
  psbook     = "$books\PowerShell"
  psbooks    = "$books\PowerShell"
  psh        = "$books\PowerShell"
  pshell     = "$books\PowerShell"
  text       = 'c:\txt'
  txt        = 'c:\txt'
}
# Import-Module "$Home\Documents\WindowsPowerShell\Set-LocationFile.ps1"
. "$Home\Documents\WindowsPowerShell\Scripts\Set-LocationFile.ps1"

Function Set-GoAlias {
  [CmdletBinding()]param(
    [Parameter(ValueFromPipeLine,ValueFromPipelineByPropertyName)][Alias('Name')]  [string[]]$Alias,
    [Parameter(ValueFromPipeLine,ValueFromPipelineByPropertyName)][Alias('PSPath')][string[]]$Path)
  Begin {
    If (!(get-variable gohash -ea ignore -Scope Global)) { $Global:GoHash = [ordered]@{} }
  }
  Process {
    ForEach ($A in $Alias) {
      If ($Path) {
        $P, $Path = $Path
        $A = $A -replace '\W+' -replace '374DE290123F4565916439C4925E467B', 'Downloads'
        Write-Verbose "Add to GoHash: $A $Path"
        if ($Global:goHash.Contains($A)) { $Null = $global:goHash.Remove($A) }
        $Null = $Global:goHash += @{$A = $P}
      }
    }
  }
  End {
    ForEach ($Name in $goHash.Keys) {
      If (Get-Alias $Name -ea Ignore) { Remove-Item Alias:\$Name -Force -ea Ignore }
      Try {
        If ($goHash.$Name -and
            (Test-Path $goHash.$Name -PathType Container -ea Ignore)) {
          Write-Verbose "New-Alias $Name Set-GoLocation -force -scope Global -ea STOP"
                         New-Alias $Name Set-GoLocation -force -scope Global -ea STOP
        }
      } Catch { Write-Warning "Can't recreate Alias $Name Set-GoLocation" }
    }
  }
}
Set-GoAlias Get-UserFolder
# CD process/service

Function Set-GoLocation {
  [Alias('gd','g','gdp','gop')]
  [CmdletBinding()]param (
    [Parameter(Position='0')][string[]]$path                      = @(),
    [Parameter(Position='1')][string[]]$subdirectory              = @(),
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$Args = @(),
    [Alias('PDirectory','PushDirectory')][switch]$pushd,
                                         [string]$StackName       = '',
    [switch]$showInvocation   # for testing
  )
  Begin {
    Write-Verbose "$(LINE) Start In: $((Get-Location).path)"
    if ($showInvocation) { Write-Verbose "$($Myinvocation | out-string )" }
    $InvocationName = $MyInvocation.InvocationName
    If (!(get-variable gohash -ea ignore -Scope Global)) { $Global:GoHash = [ordered]@{} }
    write-verbose "$(LINE) Path: $Path InvocationName: $InvocationName"
    If ($PushD -or $InvocationName -in'gdp','gop') {
      $Stack = If ($PSBoundParameters.ContainsKey('StackName')) {
        @{ StackName = $StackName }
        $Null = $PSBoundParameters.Remove('StackName')
      } Else { @{} }
      $Null = Push-Location '.' @Stack
      If ($PSBoundParameters.ContainsKey('PushD')) {
        $Null = $PSBoundParameters.Remove('PushD')
      }
    }
    $GoKeys = $goHash.Keys
    Function TestKeyPath {
      Param([string]$Arg='')
      If ($Arg) {
        ForEach ($Key in ($goKeys -match "^$Arg")) {
          If (Test-Path ($Path = $goHash.$Key)) { Return $Path }
        }
      }
    }
  }
  Process {
    try {
      If ($goHash.Contains($InvocationName) -and
          (Test-Path $goHash.$InvocationName -PathType Container -ea Ignore)) {
        Write-Verbose "Using InvocationName: $($goHash.$InvocationName)"
        Microsoft.PowerShell.Management\Set-Location $goHash.$InvocationName -ea STOP
      } ElseIf ($Path) {
        Write-Verbose "Not in hash"
        $P, $Path = $Path
        If ($goHash.Contains($P)     -and
            ($Location = $goHash.$P) -and
            (Test-Path $Location)) {
          Microsoft.PowerShell.Management\Set-Location $Location -ea STOP
        } ElseIf (Test-Path $P -PathType Container -ea Ignore) {
          Microsoft.PowerShell.Management\Set-Location $P -ea Ignore
        } ElseIf ($KeyPath = TestKeyPath $P) {
          Microsoft.PowerShell.Management\Set-Location $KeyPath
        } Else {
          Write-Verbose "$(Get-ChildItem "$P*" -ea STOP -dir | Select -first 1 | ForEach FullName)"
          Microsoft.PowerShell.Management\Set-Location (
            Get-ChildItem "$P*" -ea STOP -dir | Select -first 1 | ForEach FullName
          )
        }
      }
      $AllArgs = @($Path) + $SubDirectory + $Args
      Write-Verbose "Finished with First part of first param [$AllArgs]"
      ForEach ($P in $AllArgs) {
        Write-Verbose "ForEach $P in AllArgs"
        If ($P -and (Test-Path $P -PathType Container -ea Ignore)) {
          Write-Verbose "cd to $P"
          $Dir = Get-ChildItem -path .\ -filter "$P" -ea STOP -dir | Select -first 1 | ForEach FullName
          Write-Verbose "P: [$P] GCI: [$Dir]"
          If ($Dir) { Microsoft.PowerShell.Management\Set-Location $Dir }
        } ElseIf ($P) {
          Write-Verbose "cd to $P*"
          Write-Verbose "GCI: Get-ChildItem -path .\ `"$P*`" -ea STOP -dir | Select -first 1 | ForEach FullName"
          $Dir = Get-ChildItem -path .\ -filter "$P*" -ea STOP -dir | Select -first 1 | ForEach FullName
          Write-Verbose "P: [$P] GCI: [$Dir]"
          If ($Dir) { Microsoft.PowerShell.Management\Set-Location $Dir }
        }
      }
    }  catch {
      Write-Verbose $_
    }
    write-verbose "$(LINE) Current: $((Get-Location).path)"
  }
  End {}
}

# Utility Functions (small)
$IsOdd = { If ($_ -and ($_ -as [Int]) -and $_ % 2) { $_ }}
filter Where-Odd { Where-Object -InputObject $_ -FilterScript $IsOdd }
filter Test-Odd  { param([Parameter(valuefrompipeline)][int]$n) [boolean]($n % 2)}
filter Test-Even { param([Parameter(valuefrompipeline)][int]$n) -not (Test-Odd $n)}
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
  Get-Date "$date" ?f "yyyy-MM-ddTHH:mm:ss-ddd"
}
#([System.TimeZoneInfo]::Local.StandardName) -replace '([A-Z])\w+\s*', '$1'
Function Get-SortableDate {
  [CmdletBinding()]param([DateTime]$Date = (Get-Date))
  Get-Date $date -Format 's'
}
#$Myinvocation
#Resolve-Path $MyInvocation.MyCommand -ea ignore
#if ($myinvocation.pscommandpath) {$myinvocation.pscommandpath}
write-warning "$(Get-Date -Format 'HH:mm:ss') $(LINE) Before PSReadline "
#$PSReadLineProfile = Join-Path $myinvocation.pscommandpath 'PSReadLineProfile.ps1'
$PSReadLineProfile = Join-Path (Split-Path $PSProfile) 'PSReadLineProfile.ps1'
Write-Information $PSReadLineProfile
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
  Write-Information "$(LINE) Chocolatey profile: $ChocolateyProfile"
  if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
  }
} catch {
  Write-Information "$(LINE) Chocolatey not available."
}
new-alias alias new-alias -force -Desc "Set in Profile"
Function 4rank ($n, $d1, $d2, $d) {"{0:P2}   {1:P2}" -f ($n/$d),(1 - $n/$d)}
Write-Information ("$(LINE) Use Function Get-PSVersion or variable `$PSVersionTable: $(Get-PSVersion)")
Function down {Set-Location "$env:userprofile\downloads"}
Function Get-SerialNumber {Get-WMIObject win32_operatingsystem  | Select-Object -prop SerialNumber}
Function Get-DomainRoleName {
  [CmdletBinding()]Param(
    [int32]$Role = (Get-WMIObject Win32_ComputerSystem).DomainRole
  )
  $RoleNames = @(
    'StandaloneWorkstation',
    'MemberWorkstation',
    'StandaloneServer',
    'MemberServer',
    'DomainController',
    'PrimaryDomainController'
  )
  $Count = $RoleNames.Count
  For ($i=0;$i -lt $Count; $i++) { Write-Verbose "$i = $($RoleNames[$i])" }
  Try {
    $RoleNames[$Role]
  } Catch {
    'Unknown'
  }
}

Function Get-ComputerDomain {
  Get-WMIObject win32_computersystem |
    Select-Object -property Name,Domain,DomainRole,@{
      N='RoleName';E={Get-DomainRoleName $_.DomainRole}
    }
}
Function logicaldrive {Get-WMIObject win32_logicaldisk | Where-Object {$_.drivetype -eq 3} | ForEach-Object {"$($_.deviceid)\"}}
Function fileformat([string[]]$path = @('c:\dev'), [string[]]$include=@('*.txt')) {
  Get-ChildItem -path $path -include $include -recurse -force -ea ignore | Select-Object -Object -prop basename,extension,@{Name='WriteTime';Expression={$_.lastwritetime -f "yyyy-MM-dd-ddd-HH:mm:ss"}},length,directory,fullname | export-csv t.csv -force
}
#region Script Diagnostic & utility Functions
Function Get-PSBoundParameter {
  [CmdletBinding()][Alias('PSBoundParameter','BoundParameter','IsBound')]
  Param(
    [Alias('Parm')][string]$Parameter,
    [Alias('Present','IsPresent','ContainsKey')][switch]$Boolean,
    [Alias('RemoveParameter')]                  [switch]$RemoveKey
  )
  If ($PSCmdlet -and $PSBoundParameters.ContainsKey($Parameter)) {
    If ($Boolean) { $True }
    Else {
      $PSBoundParameters.$Parameter
    }
    If ($RemoveKey) { $PSBoundParameters.Remove($Parameter) }
  } elseif ($Boolean) {
    $False
  } else {
    $Null
  }
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

write-warning "$(LINE) $(Get-Date -Format 'HH:mm:ss') After PSReadline "
Write-Information "$(Get-Date -Format 'HH:mm:ss') $(LINE) Error count: $($Error.Count)"

Function dt {param([string[]]$datetime=(Get-Date)) $datetime | ForEach-Object { Get-Date $_ -Format 'yyyy-MM-dd HH:mm:ss ddd' } }
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
    If (Get-Variable EPath -value -ea Ignore) {$Location += ";$($Env:Path)"}
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

function Load-Assembly {
  [CmdletBinding()]param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [ValidateNotNullOrEmpty()][String]$AssemblyName,
    [Switch]$Report
  )
  if ([appdomain]::currentdomain.getassemblies() -notmatch $AssemblyName){
    if ($Report) {
      Write-Output "Loading $AssemblyName assembly.";
    }
    [Void][System.Reflection.Assembly]::LoadFromPartialName($AssemblyName);
    return 1
  } else {
    if ($Report) {
      Write-Output "$AssemblyName is already loaded.";
    }
    return -1
  }
}

If (Get-Command Set-Proxy.ps1 -ea Ignore -and (get-computerdomain).domain -match 'ww9') {
 . Set-Proxy.ps1
}

#Convenience aliases for RDCMan
$Private:RDCMan   = @('C:\Program*\*\R*D*C*Man*','C:\Program*\R*D*C*Man*')
$Private:RDCMan   = Join-Path $RDCMan 'RDCMan.exe' -Resolve -EA ignore |
                      Select -First 1 # Path to RDG file
If ($RDCMan) {
  New-Alias rdcman $Private:RDCMan -Force
  New-Alias rdc    $Private:RDCMan -Force
}


# $objShell = New-Object -ComObject ("WScript.Shell")
# $objShortCut = $objShell.CreateShortcut($env:USERPROFILE + "Start Menu\Programs\Startup" + "\program.lnk")
# $objShortCut.TargetPath("path to program")
# $objShortCut.Save()

If ($PSVersionTable.PSVersion -lt [version]'5.0.0.0') {
  Function Get-Clipboard {
    [CmdletBinding()]Param(
      [ValidateSet('Audio','FileDropList','Image','Text')]$Format,
      [ValidateSet('CSV','CommaSeparatedValue','Html','Rtf','Text','UnicodeText')]
      $TextFormatType,
      [switch]$Raw,
      [switch]$Force
    )
    If ($Force -or $PSVersionTable.PSVersion -lt [version]'5.0.0.0') {
      $Forms = 'System.Windows.Forms'
      If ([appdomain]::currentdomain.getassemblies() -notmatch $Forms) {
        Add-Type -AssemblyName $Forms
      }
      $tb = New-Object System.Windows.Forms.TextBox
      $tb.Multiline = $True
      $tb.Paste()
      $tb.Text
    } else {
      If ($TextFormatType -and $TextFormatType -eq 'CSV') {
        $PSBoundParameters.TextFormatType = $TextFormatType = 'CommaSeparatedValue'
      }
      Microsoft.PowerShell.Management\Get-ClipBoard @PSBoundParameters
    }
  }
  New-Alias gcb Get-ClipBoard -force
}

Function PSBoundParameter([string]$Parm) {
  return ($PSCmdlet -and $PSCmdlet.MyInvocation.BoundParameters[$Parm].IsPresent)
}
Function Scroll {
  Param(
    $Count=(($Host.UI.RawUI.MaxWindowSize -split ',')[1]),
    [Alias('CLS','C','Erase','Blank')][switch]$ClearScreen = $False
  )
  $LinesToScroll = "`n" * $Count
  Write-Host $LinesToScroll
}
Function Lock {
  Param(
    # $Count=(($Host.UI.RawUI.MaxWindowSize -split ',')[1]),
    # [Alias('CLS','C','Erase','Blank')][switch]$ClearScreen = $False
  )
  rundll32.exe 'user32.dll,LockWorkStation'
}
Function ip4  { ipconfig | Select-String IPv4 }
Function ipv4 { ipconfig | Select-String IPv4 }

If (Test-Path 'C:\Users\Herb\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd') {
  New-Alias code 'C:\Users\Herb\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd' -Scope Global -Force
}

#Write-Warning "Before AutoHotKey definition"
$AHK = If     (Test-Path 'C:\util\AutoHotKey\AutoHotkeyU64.exe') { 'C:\util\AutoHotKey\AutoHotkeyU64.exe' }
       ElseIf (Test-Path 'C:\util\AutoHotKey\AutoHotkey.exe'   ) { 'C:\util\AutoHotKey\AutoHotkey.exe' }
       Else   { '' }
If ($AHK) {  
  #Write-Warning "AutoHotKey defined"
  Function ak { & $AHK /r C:\bat\ahk.ahk }
  Function hk { & $AHK /r C:\bat\ahk.ahk }
  $AHKFiles = @(
    'C:\bat\ahk.ahk'
    "$Home\Documents\WindowsPowerShell\Scripts\PowerShell.ahk"
  )
  If (($Host.Name -notmatch 'Visual Studio') -and
      (@(Get-Process AutoHotKey* -ea Ignore).Count -lt $AHKFiles.Count)) {
    # Write-Warning "Run AutoHotKey scripts"
    If (Get-Variable 'AHK' -ea Ignore -Value) {
      ForEach ($File in $AHKFiles) {
        If ($File -and (Test-Path $File)) {
          Write-Warning "$(FLINE) Load AHK: $File"
          & $AHK /r $File
        } Else {
          Write-Warning "$(FLINE) Script not found: [$File]"
        }
      }
    }
  }
}       

Function ToTitleCase {
  [CmdletBinding()]Param(
    [Parameter(ValueFromPipeline,ValueFromPipeLineByPropertyName)]
      [string[]]$Title=$null,
    [Alias('RemoveChars','ExcludeChars')][string]$RemoveCharacters = '$^',
    [Alias('Clean','Squash')]            [switch]$AlphaNumeric     = $False,
    [Alias('RemoveNewLine','Online')]    [switch]$Join             = $False,
    [Alias('ToLowerCase','LowerCase')]   [switch]$ForceLowerCase   = $False
  )
  Begin {
    # Separator '-', '_'  -Dash -UnderScore ;  _ is word char?
    $JoinOn = $Separator = ''
    $Results = @()
    If ($AlphaNumeric) { $RemoveCharacters = '\W' }
    $TextInfo = (Get-Culture).TextInfo
    # If (!$RemoveCharacters) { $RemoveCharacters = '$^' }
  }
  Process {
    ForEach ($L in $Title) {
      If ($ForceLowerCase) { $L = $TextInfo.ToLower($L) }
      If ($AlphaNumeric)   { $L = $L -replace '\s', $Separator }
      $Results += $TextInfo.ToTitleCase($L) -replace $RemoveCharacters
    }
  }
  End {
    If ($Results) {
      If ($Join) {
        $Results = ($Results.Trim() -join $JoinOn).trim('\s')
  	  }
      $Results
    }
  }
}
# Windows Shell Experience Host ShellExperienceHost MiraCast remote display wireless
# https://docs.microsoft.com/en-us/windows/whats-new/whats-new-windows-10-version-1809#wireless-projection-experience
# Get-WMIObject Win32_OperatingSystem | fl * | findstr /i "version build name 1809 1803 1904 1903"

<#
LAPS Email for John, Carlos
Active Directory Hardening
Some servers in Tier2?
JIT  MIM PAM


Windows Credential Manager LSASS MimKatz

RAP AD
PAD
Premiere offerings

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
if (!(where.exe choco.exe /q)) {
  "Get Chocolatey: iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
} else {
  Write-Warning "$(FLINE) Found git: $(where.exe choco.exe)"
}
if (where.exe git.exe /q) {
  "Get WindowsGit: & '$PSProfile\Scripts\Get-WindowsGit.ps1'"
} else {
  Write-Warning "$(FLINE) Found git: $(where.exe git.exe)"
}
# Temporary Fix es in Profile \ Tools
if (($es = Get-Alias es -ea ignore) -and !(Test-Path $es)) { Remove-Item Alias:es -force -ea ignore }
if (!(Get-Command es -ea ignore)) { New-Alias es "$ProfileDirectory\Tools\es.exe" -Desc "Set in Profile" }
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

$eb = '*.epub|*.pdf|*.azw|*.azw?|*.mobi|*.doc'

Function Convert-ClipBoard {
  [cmdletbinding()][Alias('clean','ccb')]param(
    [string]$Join                             = '',
    [string]$Trim                             = '',
    [Alias('Blanks')][switch]$AllowBlankLines = $False,
    [switch]$TrimAll                          = $False,
    [switch]$NoTrim                           = $False
  )
  Begin {
    $Trim = If     ($NoTrim)  { "`n"        }
            ElseIf ($TrimAll) { '\W'      }
            ElseIf ($Trim)    { $Trim     }
            Else              { '[,;:\t\s\\/]+' }
    $MinimumLength = If ($AllowBlankLines) { -1 } Else { 0 }
  }
  Process {
    (Get-ClipBoard) -split "`n+" | ForEach-Object { $_ -replace "^$($Trim)|$($Trim)$" } |
      Where-Object Length -gt $MinimumLength
  }
  End {}
}

Function Get-About {
  Param([String[]]$Name='.*')
  Begin {
    $Topics = Import-CSV "$Home\Documents\WindowsPowerShell\Reference\About_HelpTopics.csv"
  }
  Process {
    ForEach ($N in $Name) {
      $Topics | ? Name -match $N | Select-Object Name,Synopsis
    }
  }
}

$Local:Cargo = Get-Command cargo.exe -CommandType Application -ea Ignore | Select -first 1
If ($Cargo) { Import-Module posh-cargo -ea Ignore }
$Local:CoreUtils = Get-Command coreutils.exe -CommandType Application -ea Ignore  | Select -first 1
If ($CoreUtils) { New-Alias cu $CoreUtils.Definition -scope Global -force }
$Local:Diff = Get-Command diff.exe -CommandType Application -ea Ignore  | Select -first 1
If ($diff) { New-Alias diff $Diff.Definition -scope Global -force -ea Continue}


Function Select-Everything {    # es.exe everything
  [cmdletbinding(PositionalBinding=$False)][Alias('se')]param(
    [Parameter(valuefromremainingarguments)][string[]]$Args = @(),
    [String[]]$Path                                           = '',
    [Int]   $Index,
    [Alias('Number','Maximum')][UInt32] $First,
    [Alias('Omit','Offset')]   [UInt32]$Skip,
    [Alias('MoreArgs')][String[]]$AddArgs                   = @(),
    [Switch]$Directory                                      = $False,
    [Switch]$File                                           = $False,
    [switch]$Complete                                       = $False,
    [switch]$Date                                           = $False,
    [switch]$Ascending                                      = $False,
    [switch]$NoSubtitle                                     = $False,
    [switch]$NoEdition                                      = $False,
    [Alias('EBooks')][switch]$Books                         = $False,
    [switch]$PDF                                            = $False,
    [switch]$EPUB                                           = $False,
    [switch]$ZIP                                            = $False,
    [switch]$Video                                          = $False,
    [switch]$Archives                                       = $False,
    [switch]$Ordered                                        = $False
  )
  Begin {
    $SelectIndex = @()
    If ($PSBoundParameters.ContainsKey('Index')) {
      If ($Index -gt 0)   { $Index-- }  # 0 or 1 is first 1 
      $SelectIndex = If (($Index -ge 0)) { @{ Skip = $Index; First = 1 } }
                     Else                { @{ Last = $Index * -1       } }
    }
    $ExtraArgs, $Args = $Args.Where({$_ -match '^[-/]'}, 'split')
    $Local:PathX = $Null
    If ($Args -and (Test-Path $Args[0] -PathType Container -ea Ignore)) {
      $Local:PathX, $Args = @($Args)  # move 1st item fromm Args to Path
      $Local:PathX = (Resolve-Path $Local:PathX -ea Ignore).Path
      Write-Verbose "PathX: $Local:PathX Args: [$Args]"
      $Local:PathX = @($Local:PathX)
    } 
    Write-Verbose "Args: $Args"
    Write-Verbose "Extra: $ExtraArgs"
    $ArchiveExtensions = '*.zip','*.rar','*.lzw','*.7z','.gz','.gzip','.tar'
    $BookExtensions    = '*.pdf','*.azw','*.azw3','*.azw4',
                         '*.djv','*.epub','*.djvu','*.mobi'
    $VideoExtensions   = '*.mp4','*.mov','*.wmv','*.mpg','*.flv','*.divx','*.rm',
                         '*.avi','*.mkv','*.mv4','*.asf','*.m4v','*.mpeg'                     
    Switch ($True) {
      $True      { $Extensions  = $Switches = @()             }
      $File      { $Switches   += '/a-d'                      }
      $Directory { $Switches   += '/ad'                       }
      $Date      { $Switches   += '-dm', '-sort-dm-ascending' }
      $Ascending { $Switches   += '-sort-dm-ascending'        }
      $PDF       { $Extensions += '*.pdf'                     } 
      $Epub      { $Extensions += '*.epub'                    } 
      $Zip       { $Extensions += '*.zip'                     } 
      $Archives  { $Extensions += $ArchiveExtensions          }
      $Video     { $Extensions += $VideoExtensions            }
      $Books     { $Extensions += $BookExtensions             }
      $PSBoundParameters.ContainsKey('First') { $Switches += '-n', $First}
      $PSBoundParameters.ContainsKey('Skip' ) { $Switches += '-o', $Skip }
      Default    {                                            }
    }
    $Extensions = @($Extensions -join '|')
    If (!$Args)    {
      $Args = @(Convert-ClipBoard).Trim() |
        Where { $_ -match '[a-z]' -and $_ -notmatch '^(?-i:Downloaded)$' } | 
        Select -first 1
      Write-Verbose "$(FLINE) Args: [$($Args -join " `n")]"  
      #      -replace '^([_\s]*Download[_\s*]|\W+)$' | 
      If ($Args -and ($Args[0] -ceq 'Downloaded')) { $Null, $Args = $Args }
      If ($NoSubtitle) { $Args = $Args -replace ':.*' }
      Write-Verbose "Begin-NoSubtitle: $Args" ;
      If ($NoEdition)  { $Args = $Args -replace 
        '((\d{1,2}\s*(st|nd|rd|th)*)|first|second|third|([fsent][eiolwh][-a-z]+th))\s*ed.*$' }
      Write-Verbose "Begin-NoEdition: $Args" ;
    }
  }
  Process {
    $Args = ($Args -split '\W+').trim()                  | 
      Where-Object   { $_ -and $_ -notmatch '^-?verbo' } | 
      ForEach-Object { Write-verbose "[$_]"; $_        }
    If ($Ordered -or $Complete) {
      $Args = $Args.trim() -join '*' -replace '[\s*]{2,}', '*'
      If (!$Complete) { $Args = "*$Args*" }
    }
    Write-Verbose "es $Local:PathX $Switches $args $Extensions $ExtraArgs" ;
    ForEach ($Line in @(echoargs @Local:PathX @Switches @Args @AddArgs @Extensions @ExtraArgs)) { Write-Verbose $Line }
    Write-Verbose "$(FLINE) SelectIndex:`n$($SelectIndex | Out-String )"
    es @Local:PathX @Switches @Args @AddArgs @Extensions @ExtraArgs |
      Select-Object $SelectIndex |
      ForEach-Object -Begin { $LineCount = 0 } { $LineCount++; $_ }
  }
  End {
    If (!$LineCount) {
      Write-Warning "NOT Found: es $Local:PathX $args $Extensions $ExtraArgs"
    }
  }
}

<#
80,445,3389,5985 | ForEach-Object {
  $Port = $_ 
  ‘Server1’, ‘Server2’, ‘Server3’ | ForEach-Object {
    Test-NetConnection -ComputerName $_ -Port $Port
  }
}
#>

# es $PWD -dm -size dm:>2019/10/19 -sort-dm-ascending file: | sls -not '\.git','PostMan','Google','Everything','Microsoft\\Windows','CryptnetUr','McAfee','NTUSER'
Function Get-Changed {
  [cmdletbinding()][Alias('gcf')]param(
    [string[]]$Path = @(),
    [Alias('Since','DateTime')][DateTime]$After = (Get-Date).AddDays(-1),
    [Switch]$Today = $False,
    [Parameter(ValueFromRemainingArguments=$true)]$Args
  )
  If ($Today) { $After = Get-Date 0:00 }
  $Date = @('dm:>' + (Get-Date $After -Format 's'))
  If (!$Path) {
    Write-Warning "es -dm -size $Date -sort-dm-ascending file: $Args"
    es -dm -size @Date -sort-dm-ascending file: @Args
  }
  ForEach ($P in $Path) {
    $P = @($P)
    Write-Warning "es $P -dm -size $Date -sort-dm-ascending file: $Args"
    es @P -dm -size @Date -sort-dm-ascending file: @Args
  }
}

Function Get-Length { $r = $input | measure -sum Length -Maximum; [PSCustomObject]@{
    Count       = '{0,5:N0}'  -f $R.Count
    TotalLength = '{0,12:N0}' -f $R.Sum
    TotalGB     = '{0,7:N3}'  -f ($R.Sum     / 1GB)
    Maximum     = '{0,7:N3}'  -f ($R.Maximum / 1GB)
  }
}

$UsePostloadProfile = [Boolean](Get-Variable UsePostloadProfile -value -ea Ignore)
Get-ExtraProfile 'Post' -PostloadProfile:$UsePostloadProfile | ForEach-Object {
  try {
    $Private:Separator = "`n$('=' * 72)`n"
    $Private:Colors    = @{ForeGroundColor = 'Blue'; BackGroundColor = 'White'}
    $Private:StartTimeProfile  = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    try { $Private:ErrorCountProfile = $Error.Count } catch {}
    Write-Host "$($Private:Separator)$($Private:EndTimeProfile) Extra Profile`n$_$($Private:Separator)" @Private:Colors
    . $_
  } catch {
    Write-Warning "$(FLINE) ERROR sourcing: $_`n`n$_"
  } finally {
    $Private:EndTimeProfile  = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $Private:Duration = ((Get-Date $Private:EndTimeProfile) - (Get-Date $Private:StartTimeProfile)).TotalSeconds
    Write-Host "$($Private:Separator)$($Private:EndTimeProfile) Duration:$($Private:Duration) seconds Extra Profile`n$_$($Private:Separator)" @Private:Colors
  }
}

If (($PSRL = Get-Module PSReadLine -ea 0) -and ($PSRL.version -ge [version]'2.0.0')) {
  Remove-PSReadLineKeyHandler ' ' -ea Ignore
}
remove-item alias:type       -force -ea Ignore
new-alias   type Get-Content -force -scope Global -ea Ignore

$Private:Duration = ((Get-Date) - $Private:StartTime).TotalSeconds
Write-Warning "$(LINE) $(Get-Date -Format 'HH:mm:ss') New errors: $($Error.Count - $ErrorCount)"
Write-Warning "$(LINE) Duration: $Private:Duration Completed: $Profile"

If ((Get-Command git -ea Ignore) -and (Get-Module Posh-Git -ea Ignore -ListAvailable)) {
  Import-Module Posh-Git
}

If (Test-Path "$Home\Documents\WindowsPowerShell\ProfileHansenApost.ps1" ) {

  . "$Home\Documents\WindowsPowerShell\ProfileHansenApost.ps1"
}

Set-StrictMode -Version Latest

<#
$ScriptBlock = {
  $hashtable = @{}
  foreach( $property in $this.psobject.properties.name ) {
    $hashtable[$property] = $this.$property
  }
  return $hashtable
}
$memberParam  = @{
  MemberType  = ScriptMethod
  InputObject = $myobject
  Name        = "ToHashtable"
  Value       = $scriptBlock
}
Add-Member @memberParam

$TypeData = @{
    TypeName   = 'My.Object'
    MemberType = 'ScriptProperty'
    MemberName = 'UpperCaseName'
    Value = {$this.Name.toUpper()}
}
#Update-TypeData @TypeData
#https://kevinmarquette.github.io/2016-10-28-powershell-everything-you-wanted-to-know-about-pscustomobject/#adding-object-methods

Function Set-Owner Set-FileOwner Set-ObjectOwner ???
cacls History /c /t /e /g "$(whoami):F"
wmic path Win32_LogicalFileSecuritySetting where Path="C:\\windows\\winsxs" ASSOC /RESULTROLE:Owner /ASSOCCLASS:Win32_LogicalFileOwner /RESULTCLASS:Win32_SID
wmic path Win32_LogicalFileSecuritySetting where Path="C:\\Users\\A469526\\AppData\Local" ASSOC /RESULTROLE:Owner /ASSOCCLASS:Win32_LogicalFileOwner /RESULTCLASS:Win32_SID
wmic path Win32_LogicalFileSecuritySetting where Path="C:\\Users\\A469526\\AppData\\Local" ASSOC /RESULTROLE:Owner /ASSOCCLASS:Win32_LogicalFileOwner /RESULTCLASS:Win32_SID
wmic path Win32_LogicalFileSecuritySetting where Path="C:\\Users\\A469526\\AppData" ASSOC /RESULTROLE:Owner /ASSOCCLASS:Win32_LogicalFileOwner /RESULTCLASS:Win32_SID
wmic --% path Win32_LogicalFileSecuritySetting where Path="C:\\Users\\A469526\\AppData" ASSOC /RESULTROLE:Owner /ASSOCCLASS:Win32_LogicalFileOwner /RESULTCLASS:Win32_SID
. D:\a469526\Documents\WindowsPowerShell\PSReadLineProfile.ps1
cd (get-userfolder documents).folder
(get-userfolder documents).tostring()
#>

# 1..255 | % { Start-ThreadJob -Name "TestThread$_" { ForEach ($Port in 80,135,445) { 
Function Test-TCPPort {  # check actual IP & Port combination
  [Alias('Test-TCPService','TestTCP','tcp')][CmdLetBinding()]Param(
    [string]$Server='127.0.0.1',
    [Uint16]$Port=135,
    [Alias('Wait','MaxWait')]$TimeOut=3000
  )
  if ($TimeOut -lt 30) { $TimeOut *= 1000 }
  $Failed = $False
  $Succeeded = $True
  try {
    $ErrorActionPreference = 'Continue'
    $tcpclient = new-Object system.Net.Sockets.TcpClient
    $Start = Get-Date
    Function Elapsed { param($Start = $Start) '{0,5:N0}ms' -f ((Get-Date) - $Start).TotalMilliseconds }
    $iar = $tcpclient.BeginConnect($Server, $port, $null, $null) # Create Client
    $wait = $iar.AsyncWaitHandle.WaitOne($TimeOut,$false)         # Set timeout
    if (!$wait) {                                                 # Check if connection is complete
        $Failed = $True
    }  else {
      $tcpclient.EndConnect($iar) | out-Null
      if (!$?) {
        $failed = $true
      }
    }
  } catch {
    $Failed = $True
  } finally {
    if ($tcpclient.Connected) {
      $null = $tcpclient.Close
    }
  }
  !$failed  # Return $true if connection Establish else $False
}

# Test-TCPPort "192.168.239.$($args[0])" $Port } } -ArgumentList $_  -ThrottleLimit 255 } ; While ($Threads = Get-Job -State Completed -HasMoreData $True) { ForEach ($Thread in $Threads) { If ($Thread.State -ne 'Completed') { Continue } "Job: $(Receive-Job $Thread)"; Remove-Job $Thread } 
 