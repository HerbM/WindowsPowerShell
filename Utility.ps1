#region Script Diagnostic & utility Functions

#region Definitions
  <#         
			#   function Get-CurrentLineNumber { $MyInvocation.ScriptLineNumber }
			#   function Get-CurrentFileName   { split-path -leaf $MyInvocation.PSCommandPath   }   #$MyInvocation.ScriptName
			#   function Get-CurrentFileLine   
			#   function Get-CurrentFileName1  
			#   function Get-SortableDate 
			#   function Get-FormattedDate ([DateTime]$Date = (Get-Date)) 
			#   function Write-Log 
			#   function Log-ComputerInfo 
			#   function ExitWithCode($exitcode) 
			#   function GetVerbose {   # return a --verbose switch string for calling other programs or ''
			#   function Make-Credential([string]$username, [string]$password) 
			#   function Get-ErrorDetail 
			#   function MyPSHost 
			#   function Convert-HashToString1($ht) 
			#   function Convert-HashToString($Hash, [string]$prefix='-', 
			#   function Get-AdminRole() 
			#   function PSBoundParameter([string]$Parm) 
			#   function Remove-MappedDrive([string]$name) 
			#   function Get-MappedDrive([string]$name, [string]$share, [string]$username="", [string]$password="") 
			#   function Get-AESKey([uint16]$length=256) 
			#   function Decrypt-SecureString ($secureString) 
			#   function Get-PlainText ([string]$string, [byte[]]$key=$(Get-Temporary)) 
			#   function Set-EncryptedString([string]$content, [byte[]]$Key) 
			#   function Get-Temporary 
			#   function Get-EncryptedString($Secret, [byte[]]$key) 
			#   function Set-EncryptedContent([string]$Path, [string]$content, [switch]$Append) 
			#   function Get-EncryptedContent([string]$Path, [byte[]]$key, [switch]$Delete) 
			#   function Get-StandardWindowsAdministrator { @('Administrator','Admin999','Admin888','admin123', 'BuildAdmin') }
			#   function Get-CredentialContent ([string]$ZipFile, [string]$CredFile, $pwd = "NOTHING") 
			#   function Import-SecureZipOLD 
			#   function Import-SecureZip 
			#   function New-Zipfile ([string]$ZipFile, [string]$contents, $pwd = "NOTHING") 
			#   function Get-LocalCredential 
			#   function Fix-Encoding([string]$xmlstring, [string]$enc=$encoding) 
			#   Function Start-ProcessWithWait ([string]$cmd, [string[]]$arg, $wait = (10 * 1000)) 
			#   function Run-CmdBatch ($Batch='APPConfig.cmd', $arguments=@(), $wait=(2*60*1000)) { # wait up to 2 minutes by default
			#   Function Start-ProcessWithWait2 ([string]$cmd, [string[]]$arg, $wait = (10 * 1000), $cred=$null) 
			#   function Run-CmdBatch2 ($Batch='APPConfig.cmd', $arguments=@(), $wait=(2*60*1000), $cred=$null) { # wait up to 2 minutes by default
			#   function Add-ADDMAccount 
			#   function Reboot-Computer($delay=15) 
			#   function Get-LocalAdministrator 
			#   function Set-Password([string]$UserName, [string]$Password, [byte[]]$key) 
			#   function New-LocalUser 
			#   function Get-Cleartext 
			#   function Rename-LocalAdmin($NewName='Admin999', $Password, [byte[]]$key, [switch]$force,[switch]$HardForce) 
			#   function Get-LocalAdminName {(Get-LocalAdministrator).Name}
			#   function Get-DomainRoleName ([int32]$Role) 
			#   function Get-Drive 
			#   function Get-DomainInformation 
			#   function Delete-AppDirectoryAtNextBoot 
			#   function Get-SystemBootTime  
			#   function Get-ComputerDomain 
			#   function Get-ComputerNetBiosDomain 
			#   function Get-LocalUserList() 
			#   function LocalUserExists([string]$user, [string []]$userlist = @()) 
			#   function Delete-LocalUser([string []]$users) 
			#   function Add-UserToGroup ([string]$user, [string]$group='Administrators') 
			#   function Add-GroupMember 
			#   function Add-LocalUser([string]$user, [string]$password, [string]$comment="") 
			#   Function Get-TempPassword() 
			#   Function Get-TempName([UINT16]$Length=8, [switch]$Alphabetic, [switch]$Numeric) 
			#   function Get-RegValue([String] $KeyPath, [String] $ValueName) 
			#   function Get-AdminRole() 
			#   function Copy-DirectoryTree([string]$sourcepath, [string]$destpath) 
			#   function Remove-Parameters 
			#   function Get-PresentSwitchName([string[]]$switch) 
			#   function Get-SerialNumber 
			#   function Get-MACAddress 
			#   function Get-UUID 
			#   function New-UniqueName() { [System.IO.Path]::GetRandomFileName() }  
			#   function New-TemporaryDirectory ([string]$Path = '.\temp', [switch]$Create) 
			#   function testlog () 
			#   function testfl () 
			#   function Set-ExecutionPolicyRemotely([string]$Computername, [string]$ExecutionPolicy, $cred) 
			#   function Set-FirewallOff 
			#   function Get-OS {(Get-WmiObject -class Win32_OperatingSystem -ea 0).caption}
			#   function Is-Windows2008? {return ((Get-OS) -match '2008')}
			#   function Get-EnvironmentVariable([string] $Name, [System.EnvironmentVariableTarget] $Scope) 
			#   function Get-EnvironmentVariableNames([System.EnvironmentVariableTarget] $Scope) 
			#   function Update-Environment 
			#   function Is-RebootPending? 
			#   function Clear-All-Event-Logs ($ComputerName="localhost") 
			#   function WaitFor-WSMan 
			#   function Test-Json 
			#   function Get-CharSet ([string]$start='D', [string]$end='Q') 
			#   function Get-UnusedDriveLetter($LetterSet) 
			#   function Get-ServiceStatus ($Name) 
			#   Function Write-ImageInfoLog([string]$CorrelationID, [string]$IPAddress, 
			#   function Get-HostsContent ($path="$Env:SystemRoot\System32\drivers\etc\hosts") { gc $path -ea 0 }
			#   function Replace-HostRecord ([string[]]$hosts, [string]$IP, [string[]]$Name, [string]$comment) 
			#   function Add-HostRecord ([string]$IP, [string[]]$Name, [string]$comment='') 
			#   function IsHealthCareCustomer? ([string]$Customer=$Customer) 
			#   function Get-BuildCDC () 
			#   function Set-BigfixEnvironment ([string]$BuildCDC=$BuildCDC, [string]$BuildCustomer=$Customer, [switch]$Permanent) 
			#   function Sort-ConnectionSpeed 
		 
  #>
  
#endregion

#region Definitions
function Get-CurrentLineNumber { 
  $Invocation = Get-Variable MyInvocation -value -ea 0 2>$Null
  If (!$Invocation) { $Invocation = $MyInvocation } 
  $Invocation.ScriptLineNumber 
}
#function Get-CurrentFileName  { $MyInvocation.MyCommand.Name   }   #$MyInvocation.ScriptName
function Get-CurrentFileName   { split-path -leaf $MyInvocation.PSCommandPath   }   #$MyInvocation.ScriptName
function Get-CurrentFileLine   { 
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

try {
#    if (![boolean](get-alias line -ea 0)) {
      New-Alias -Name   LINE   -Value Get-CurrentLineNumber -Description 'Returns the current (caller''s) line number in a script.' -force -Option allscope
      New-Alias -Name __LINE__ -Value Get-CurrentLineNumber -Description 'Returns the current (caller''s) line number in a script.' -force -Option allscope
      New-Alias -Name   FILE   -Value Get-CurrentFileName   -Description 'Returns the name of the current script file.' -force             -Option allscope
      New-Alias -Name   FLINE  -Value Get-CurrentFileLine   -Description 'Returns the name of the current script file.' -force             -Option allscope
      New-Alias -Name   FILE1  -Value Get-CurrentFileName1  -Description 'Returns the name of the current script file.' -force             -Option allscope
      New-Alias -Name __FILE__ -Value Get-CurrentFileName   -Description 'Returns the name of the current script file.' -force             -Option allscope
#    } 
} catch {}

function Get-SortableDate {
  [CmdletBinding()]param([DateTime]$Date = (Get-Date)) 
  Get-Date $date -format 's'
}

function Get-FormattedDate ([DateTime]$Date = (Get-Date)) {
  Get-date "$date" ?f "yyyy-MM-ddTHH:mm:ss-ddd"
}

if (Get-Command Write-Log -CommandType alias -ea ignore) { 
  remove-item Alias:Write-Log -force -ea ignore 
}
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
    if (-not (Test-Variable LogFilePath)) { 
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
    $ec   = $_.ScriptStackTrace; $em = $_.Exception.Message; $in = $_.InvocationInfo.PositionMessage
    $description =  "$(FLINE) Catch $in $ec, $em"
    # "Logging: $description" >> $LogFilePath
  }  
}

Function Test-Variable {
  [CmdletBinding()]param(
    [string]$Name
  )
  Get-Variable -name $Name -ea Ignore -valueOnly # -Scope $Scope
}
New-Alias TVN Test-Variable -Force -ea Ignore

Function Write-LogSeparator {
  param(
    [string]$Separator = '=',
    [uint16]$Width = 60,
    [Alias('Repeat')][uint16]$Count = 2
  )
  if ( (Test-Variable LogFilePath) -and 
      ((Test-Variable LogLevel)    -and $LogLevel -gt 0) -and 
      (Test-Path $LogFilePath -ea Ignore)
  ) {
    For ($i=0; $i -lt $Count; $i++) {
      write-log ($Separator * $Width)
    }
  }
} 

function Log-ComputerInfo {
  param([string]$CorrelationID='', [string]$IPAddress='', [string]$ComputerName='', 
        [string]$Customer='',        [string]$OS='',        [string]$Notify
  )
  try {
    if (!$AppPath) { $AppPath = 'C:\APP' }
    $LogInfo = Join-Path $AppPath 'Log'
    if (!(Test-Path $LogInfo -ea 0)) { md $LogInfo }
    $LogInfo = Join-Path $LogInfo 'ComputerInfo.txt'
    $line = [pscustomobject]@{
      'DateTime'       = (Get-Date -f "yyyy-MM-dd-ddd-HH:mm:ss") #### (Get-Date)
      'CorrelationID'  = $CorrelationID
      'IPAddress'      = $IPAddress
      'ComputerName'   = $ComputerName
      'Customer'         = $Customer
      'OS'             = $OS
      'Notify'         = $Notify
    }    
    $line | Export-Csv -Path $LogInfo -Append -NoTypeInformation -erroraction Silentlycontinue -force -enc ASCII
  } catch {
    write-log "$(FLINE) Unable to log ComputerInfo"
  }  # just ignore errors
}
  
function ExitWithCode($exitcode) {
  $host.SetShouldExit($exitcode)
  exit
}

function GetVerbose {   # return a --verbose switch string for calling other programs or ''
  if ($PSBoundParameters['Verbose']) {return '-verbose'}
  return ''
}

function Make-Credential([string]$username, [string]$password) {
  $Username = $Username.trim(); 
  $Password = $Password.trim(); 
  # write-log "$(FLINE) U/P [$username] [$password]" 
  $cred = $null
  if ($Password) {
    $secstr = ConvertTo-SecureString -String $password -AsPlainText -Force
    if ($secstr) {
      $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$secstr
    }
  }  
  $cred
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
    return "PowerShell host not found"
  }
}

<# get-host
Name             : ConsoleHost
Version          : 5.0.10586.117
InstanceId       : 07bb2413-c3a8-46d2-ba81-b004bf6b6281
UI               : System.Management.Automation.Internal.Host.InternalHostUserInterface
CurrentCulture   : en-US
CurrentUICulture : en-US
PrivateData      : Microsoft.PowerShell.ConsoleHost+ConsoleColorProxy
DebuggerEnabled  : True
IsRunspacePushed : False
Runspace         : System.Management.Automation.Runspaces.LocalRunspace
#>

function Convert-HashToString1($ht) {
  [string[]]$outarray = @()
  foreach($pair in $ht.GetEnumerator()) {
    $outputArray += "-$($pair.key) '$($pair.Value)'"
  }
  ' ' + ($outArray -join ' ') + ' '
}

function Convert-HashToString($Hash, [string]$prefix='-', 
  [string]$Separator=' ', [string]$Quote="'") {
  [string[]]$pairs = @()
  foreach($key in $Hash.keys) {
    $pairs += "$Prefix$Key$Separator$quote$($Hash[$key])$quote"
  }
  $pairs -join ' '
}


function Get-AdminRole() {
  ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

function PSBoundParameter([string]$Parm) {
  return ($PSCmdlet -and $PSCmdlet.MyInvocation.BoundParameters[$Parm].IsPresent)
}

  function Remove-MappedDrive([string]$name) {
    $name = $name -replace ':.*$', ''
    if (test-path $name) {Remove-PSDrive $name -force -ea 0}
    return (-not (test-path "$($Name):"))
  }

  function Get-MappedDrive([string]$name, [string]$share, [string]$username="", [string]$password="") {
    $name = $name -replace ':$', ''
    $credential = Make-Credential $username $password
    $GMDError = ''
    try { $drive = new-psdrive $name filesystem -root $share -cred $credential -ea 0 -ev GMDError}
    catch { 
      Write-Log "$(FLINE) failed new-psdrive on $share with credentials $username" 
      Write-Log "$(FLINE) " 
    }
    $Succeeded = Test-Path "$($name):\" -PathType 'Container' -ea 0
    write-log "$(FLINE) User:$username PSDriveRoot:$($name):\ Share:$Share Connected: $Succeeded"
    if ($GMDError) { write-log "$(FLINE) $GMDError" }
    return $Succeeded
  }

function Get-AESKey([uint16]$length=256) {
  if ($length -gt 32) { [uint16]$length = $length / 8 }
  $length = &{switch ($length) {
    {$_ -le  8 } {  8; break }
    {$_ -le 16 } { 16; break }
    default {32}
  }}
  $AES = New-Object Byte[] $length
  [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AES)
  $AES
}

function Decrypt-SecureString ($secureString) {
  [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($secureString))
}

function Get-PlainText ([string]$string, [byte[]]$key=$(Get-Temporary)) {
  if (!$Key) {$key = (Get-Temporary) }
  write-log "$(LINE) [$string] [$($key -join '-')]"
  Decrypt-SecureString (Get-EncryptedString $string $key)
}

function Set-EncryptedString([string]$content, [byte[]]$Key) {
  Write-Log "$(FLINE) Set-EncryptedString"
  $secstr = ConvertTo-SecureString -String $content -AsPlainText -Force
  if (!$Key) { $Key = Get-AesKey }
  $EncryptedString = $SecStr | ConvertFrom-SecureString -Key $Key
  @{'Key' = $Key; 'Content' = $EncryptedString}
}

function Get-Temporary {
  [OutputType([byte[]])]param()
  $t = @(
    '76492d1116743f0423413b16050a5345MgB8AFkA'
    'VQBmAHIAWQBwAGcATwBoAHYAYgBHAHMAMgBiAHIA'
    'MwB2AFcAMQBjAEEAPQA9AHwAMQAxADQAZAA0ADYA'
    'YQA5ADAAMgA5ADUAOABkADYAYwA4ADUANAA2ADAA'
    'NwAzAGMAMgA0ADMAOQA2ADkAYQBmADEAYwBlADAA'
    'MQAxADMANABmADYAOAA0AGYAMQA2ADEAMQA4ADEA'
    'ZAA3ADYAYwAzAGEAMwBjADYAMQA3AGYAZQAwADYA'
    'OAA5AGQAZQBiADEAMgA3ADEANgA0ADIAZgAwADUA'
    'MwAwADcAZAA0ADYAZQAyADcAMwBlADMAZABjADEA'
  ) -join ''; @(93,62,47,237,126,69,254,253,70,226,102,201,101,112,94,197,
                204,155,147,148,106,160,38,43,96,237,98,227,149,251,97,48)
}

function Get-EncryptedString($Secret, [byte[]]$key) {
  $Secret | ConvertTo-SecureString -Key $Key
}

function Set-EncryptedContent([string]$Path, [string]$content, [switch]$Append) {
  Write-Log "$(LINE) path: $Path"
  $secstr = ConvertTo-SecureString -String $content -AsPlainText -Force
  $Key = Get-AesKey
  $EncryptedString = $SecStr | ConvertFrom-SecureString -Key $Key
  if ($Append) { Append-Content $Path $EncryptedString }
  else         { Set-Content    $Path $EncryptedString }
  $Key
}

function Get-EncryptedContent([string]$Path, [byte[]]$key, [switch]$Delete) {
  if (! $Path) { return '' }
  $EncString = Get-Content $Path -ea 0
  if ($Delete) {del $path -force -ea 0}
  $EncString | ConvertTo-SecureString -Key $Key 
}

function Get-StandardWindowsAdministrator { @('Administrator') }

function Get-CredentialContent ([string]$ZipFile, [string]$CredFile, $pwd = "NOTHING") {
  $c = ''
  if (!$AppPath) { $AppPath = 'c:\APP' }
  $7z = Resolve-Path (Join-Path $AppPath ".\7z.exe")
  $p = "Start$s$w!"
  $key = (gci cert:\currentuser\my\O850R45PO1P68R76N8P800R59S2901NQ54P0NPO9).publickey.encodedkeyvalue.rawdata[10..19] -join ''
  $p = $p -replace "($w)", "$w$key"
  $zipargs = @('e', '-so', '-t7z', '-y', "-p$p", '-bse0', '-bsp0', '-bso0', $ZipFile, $CredFile)
  # write-log "$(LINE) 'e', '-y', `"-p`$p`", $ZipFile, $CredFile" 3
  # write-log "$(LINE) &$7z $zipargs" 
  $zo = &$7z @zipargs 2>$null
  $ExitCode = $LastExitCode
  write-log "$(LINE) did unzip Exitcode: $exitcode"
  $zo
}


function Import-SecureZip {
  [CmdletBinding()]param (
    [string]$zipfile, 
    [string]$CredFile,
    [string]$Certificate='cert:\currentuser\my\O850R45PO1P68R76N8P800R59S2901NQ54P0NPO9'
  )
  #write-log "$(FLINE) zipargs: $($zipargs -join "  ")"
  if (!$AppPath) { $AppPath = 'c:\APP' }
  if (!$ZipFile) { $ZipFile = Join-Path $AppPath Credential.zip } 
  if (!$CredFile) { 
    $CredFile = if ($ZipFile -match '\bCredential.zip\b') {"CredDomain.txt" } 
    elseif ($ZipFile -match '\bLocalCred.zip\b') { 'LocalCred.txt' }
  }
  $7z = "$AppPath\7z.exe"
  $s = (1,2,3,4 -join ''); $w = (($env:WinDir -split '\\')[1]).tolower();$p = "Start$s$w!"
  $key = (gci $Certificate).publickey.encodedkeyvalue.rawdata[10..19] -join ''
  $p = $p -replace "($w)", "$w$key"
  $zipargs = @('e', '-so', '-t7z', '-y', "-p$p", '-bse0', '-bsp0', '-bso0', $ZipFile, $CredFile )
  #write-log "$7z $($zipargs -join ' ' )"
  $z = &$7z @zipargs # 2>$Null
  $ExitCode = $LastExitCode
  if ($ExitCode -ne 0) { 
     write-log "$(FLINE) Zip exited with $ExitCode : $z[0]"; 
     return '' 
  }
  if (gcm write-log -ea 0) { write-log     "zipfile:  $ZipFile  credfile: $CredFile" }
  else                     { write-verbose "zipfile:  $ZipFile  credfile: $CredFile" }
  $z[0] = $z[0] -replace '\bID|User\b', 'UserName'
  $z | ? {$_ -match '^[a-z0-9]'}
}

  function New-Zipfile ([string]$ZipFile, [string]$contents, $pwd = "NOTHING") {
    $c = ''
    $7z = "$AppPath\7z.exe"
    $p = $length
    $zipargs = @('u', '-y', "-tzip", "-p$pwd", $ZipFile, $contents)
    $zo = &$7z @zipargs
    $ExitCode = $LastExitCode
    Write-Log "$(LINE) did New-file zip $exitcode"
    if ($ExitCode -ne 0) { Write-Log "$(LINE) New-Zipfile exited with $ExitCode : $z" }
    return $c
  }

  function Get-LocalCredential {
    [CmdletBinding()]
    param(
      $zipfile   = 'C:\APP\LocalCred.zip',
      $lcredfile = '',
      $length    = '',
      [switch]$Domain,
      [switch]$raw
    )
    if ($Domain) { $zipfile = 'Credential.zip' }
    if ($zipfile -match 'LocalCred.zip'  -and !$lcredfile) { $lcredfile = 'LocalCred.txt' } 
    if ($zipfile -match 'Credential.zip' -and !$lcredfile) { $lcredfile = 'CredDomain.txt' } 
    write-verbose "$(FLINE) zip: [$zipfile]  cred: [$lcredfile]"
    $localcred = [ordered]@{}
##    if ($file = (Get-CredentialContent $zipfile $lcredfile $length "test3R179#$")) {
    if ($file = (Import-SecureZip $zipfile $lcredfile )) {
      if ($raw) { return $file }
      foreach ($line in $file) {
        $l = -split $line
        $localcred[$l[0]] = $l[1]
        #Write-Log "$(LINE) key: $($l[0]) val: $($l[1])" 1
      }
    } else {
      Write-Log "$(LINE) $lcredfile missing or empty"
    }
    $localcred
  }

  function Fix-Encoding([string]$xmlstring, [string]$enc=$encoding) {
    if ($encoding -and $xmlstring) {
      $xmlstring = $xmlstring -replace 'encoding="[^"]+"', "encoding=`"$encoding`""
    }
    return $xmlstring
  }

  Function Start-ProcessWithWait ([string]$cmd, [string[]]$arg, $wait = (10 * 1000)) {
    $Process = start-process -file $cmd -arg $arg -window hidden -verb runas -pass
    # -RedirectStandardOutput "$cmd-OUT.txt"
    if ($wait -le 60) {$wait *= 1000}   
    if ($Process) {
      Write-Log "$(FILE):$(LINE) WaitForExit $wait $cmd PID: $($Process.id)"
      $Process.WaitForExit($wait)  # return even if it hangs
      Write-Log "$(FILE):$(LINE) Cmd Config last RC: $($Process.ExitCode)"
      return $Process.ExitCode
    }
    return -999
  }

  function Run-CmdBatch ($Batch='APPConfig.cmd', $arguments=@(), $wait=(2*60*1000)) { # wait up to 2 minutes by default
    $env:HC = 'C:\AppDirectory_Windows'
    $arg = @('/c', $Batch) 
    if ($arguments) { $arg += $arguments }
    Start-ProcessWithWait 'cmd.exe' $arg -wait $wait
  }    

  Function Start-ProcessWithWait2 ([string]$cmd, [string[]]$arg, $wait = (10 * 1000), $cred=$null) {
    if ($cred) {$Process = start-process -file $cmd -arg $arg -window hidden -verb runas -pass -cred $cred -RedirectStandardOutput "$cmd-OUT.txt"} 
    else       {$Process = start-process -file $cmd -arg $arg -window hidden -verb runas -pass -RedirectStandardOutput "$cmd-OUT.txt"}  
    if ($wait -le 60) {$wait *= 1000}  
    if ($Process) {
      Write-Log "$(FILE):$(LINE) WaitForExit $wait $cmd PID: $($Process.id)"
      $Process.WaitForExit($wait)  # return even if it hangs
      Write-Log "$(FILE):$(LINE) Cmd Config last RC: $($Process.ExitCode)"
      return $Process.ExitCode
    }
    return -999
  }

  function Run-CmdBatch2 ($Batch='APPConfig.cmd', $arguments=@(), $wait=(2*60*1000), $cred=$null) { # wait up to 2 minutes by default
    $env:HC = 'C:\AppDirectory_Windows'
    $arg = @('/c', $Batch) + $arguments
    if ($cred) {Start-ProcessWithWait2 'cmd.exe' $arg -wait $wait -cred $cred} 
    else       {Start-ProcessWithWait2 'cmd.exe' $arg -wait $wait} 
  }    

  function Add-ADDMAccount {
    param ([string]$Password='')
    $ADDMBatch = 'C:\AppDirectory_Windows\AddmAccount.cmd' 
    write-log "$(LINE) Run Add addm account: $ADDMBatch"
    if (! (Test-Path $ADDMBatch)) {    
      write-log "$(LINE) Added addm account -- $ADDMBatch SKIPPED"
    } else {
      $RC = Run-CmdBatch $ADDMBatch $Password -wait 5
      write-log "$(LINE) Added addm account -- $($ADDMBatch): $RC"
      if (Test-Path $ADDMBatch) { Remove-Item $ADDMBatch -force -ea 0}
    } 
  }  

  function Reboot-Computer($delay=15) {
    $arg = @('/r', '/f', '/t', $delay)
    $process = start-process -file 'shutdown.exe' -arg $arg -window hidden -verb runas -pass
  }

  ###  function Spawn-Command([string]$Path, [string[]]$Parameters=@()) {
  ###    ##  $proc = %SA% -cred $cred `
  ###    ##    -ComputerName $IPAddress `
  ###    ##    -Class Win32_Process `
  ###    ##    -Name Create -ea 0 -ev WMI `
  ###    ##    -ArgumentList "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noprofile -ExecutionPolicy remotesigned -file $EnableRemoteScripting" `
  ###    ##    -Impersonation 3 -EnableAllPrivileges
  ###    if ($Parameters.Count) { $process = start-process -file 'PowerShell' -window hidden -verb runas -pass -arg $Parameters }
  ###    else                   { $process = start-process -file 'PowerShell' -window hidden -verb runas -pass }
  ###    $process
  ###  }
  ###  
  ###  function Spawn-Job ([string]$Path, [string[]]$Parameters=@()) {
  ###    if ($Parameters.Count) { $process = start-process -file 'PowerShell' -window hidden -verb runas -pass -arg $Parameters }
  ###    else                   { $process = start-process -file 'PowerShell' -window hidden -verb runas -pass }
  ###    $process
  ###  }
  
  
  function Get-LocalAdministrator {
    Get-WMIObject -Class Win32_Account -Filter "LocalAccount=True and SID like 'S-1-5-21%-500'" -ea 0
  }

  function Set-Password([string]$UserName, [string]$Password, [byte[]]$key) {
    try {
      if ($Password -and ($UserName -notmatch '123')) {  # don't reset password for admin123
        if ($Password.length -gt 32) {
          $Password = Get-PlainText $Password $Key
          Write-Log "$(FLINE) Long-Password: $($Password[0])" 
        }
        if ($Password) {   
          Write-Log "$(FLINE) net user $UserName $($Password[0])"
          $junk = net user $UserName $Password
        }
      }
    } catch {
      Write-Log "$(FLINE) Caught error: net user $UserName $($Password[0])"
    }    
    $UserName
  }      
  
  function New-LocalUser {
    [CmdletBinding()]param (
      [string]$UserName, [string]$Password, 
      [byte[]]$key, [string]$Description='',
      [string[]]$Groups
    ) 
    try {
      if ($Password.length -gt 32) { $Password = Get-PlainText $Password $Key }
      Write-Log "$(FLINE) Adding admin $UserName"
      $null = net user $UserName $Password /add "/Comment:$Description" 2>&1
      foreach ($Group in $Groups) { $null = net localgroup $Group $UserName /add 2>&1 }        
    } catch { 
      write-log "$(FLINE) Failed at Get-NewLocalUser $_"
    }    
    $UserName
  }      

  function Get-Cleartext {
    [CmdletBinding()]param (
      [string]$Password, 
      [byte[]]$key
    ) 
    try {
      if ($Password.length -gt 32) { $Password = Get-PlainText $Password $Key }
    } catch { 
      write-log "$(FLINE) Failed at Get-Cleartext $_"
    }    
    $Password
  }      
  
  function Rename-LocalAdmin($NewName='Admin999', $Password, [byte[]]$key, [switch]$force,[switch]$HardForce) {
    function Get-LocalAdminName {(Get-LocalAdministrator).Name}
    try {
      if ($Hardforce) { $Force = $True }
      $User = Get-LocalAdministrator
      $CurrentName = $User.name
      $result = net user $CurrentName /comment:'' 2>&1
      if (!$HardForce -and $CurrentName -ne 'admin123') {return $CurrentName}
      if ($force -or ($CurrentName -match 'admin123')) {
        if ($NewName -ne $CurrentName) { 
          $result = $User.Rename($newName)
          $CurrentName = Get-LocalAdminName
          if ($NewName -ne $CurrentName) { 
            $adminObj = [adsi]"WinNT://./$Admin,user"
            $result = $adminObj.psbase.rename($NewName)
            $CurrentName = Get-LocalAdminName
          }  
        }  
      }  else {
        Write-Log "$(LINE) Force not request: did NOT rename $CurrentName to $newName"
      }  
    } catch {
      $CurrentName = Get-LocalAdminName
      Write-Log "$(LINE) Could not rename $CurrentName to $newName"
    } finally {
      $CurrentName = Get-LocalAdminName
      Set-Password $CurrentName $Password $Key
    }
  }

<#
Domain                      : WORKGROUP
DomainRole                  : 2
PartOfDomain                : False


function Get-DomainRoleName ([int32]$Role) {
  switch ($Role) {
    0       { 'StandaloneWorkstation '  }
    1       { 'MemberWorkstation'       }
    2       { 'StandaloneServer'        }
    3       { 'MemberServer'            }
    4       { 'DomainController'        }
    5       { 'PrimaryDomainController' }
    default { 'Unknown'                 }
  }
}

function Get-Drive {
  [CmdletBinding()]param( [string]$PSProvider='FileSystem')
  # get-psdrive | ? {$_.root -match '^[A-Q]:'}
  get-psdrive -psprovider filesystem  
}
# 0x44..0x51 | % {[char]$_}
# (h).commandline | ? {$_ -match 'new-ad'}
# netsh inter ip set dns "BUR" static none
# WMIC  NICCONFIG list /format:LIST

function Get-DomainInformation {
  $domainInfo = gwmi win32_computersystem | select Domain,DomainRole,@{Name='RoleName';Expression={Get-DomainRoleName ($_.DomainRole)}},PartOfDomain,Workgroup
}
#>  

function Delete-AppDirectoryAtNextBoot {
  $AppDirectory = "$($env:SystemDrive)\AppDirectory_Windows"
  $jobname = 'Remove-DCSAppDirectoryDirectory'
  if (Test-Path $AppDirectory) {
    $cmd = "$AppDirectory\$($JobName).ps1"
    $cmdscript = @"
      if (Test-Path $AppDirectory) {
        cd "$($env:SystemDrive)\"   # make sure cmd is not in the directory
        start-sleep -s (60 * 5)     # 5 minutes
        remove-item $AppDirectory -recurse -force
        if ((!(Test-Path $AppDirectory)) -and (Get-ScheduledJob -Name $JobName -ea 0)) { 
          Unregistered-ScheduledJob -Name $JobName -Force 
        }
      }
"@
    set-content -path $cmd -value $cmdscript -force 
    $trigger = New-JobTrigger -AtStartup -RandomDelay 00:02:00
    Register-ScheduledJob -Trigger $trigger -FilePath $cmd -Name $JobName -ScheduledJobOption @{RunElevated=$True}
  }
  if ((!(Test-Path $AppDirectory)) -and (Get-ScheduledJob -Name $JobName -ea 0)) { 
    Unregistered-ScheduledJob -Name $JobName -Force 
  }
}  

function Get-SystemBootTime  {            
  $operatingSystem = Get-WmiObject Win32_OperatingSystem -ea 0               
  [Management.ManagementDateTimeConverter]::ToDateTime($operatingSystem.LastBootUpTime)            
}

function Get-ComputerDomain {
  (Get-WMIObject Win32_ComputerSystem -ea 0).domain
}

function Get-ComputerNetBiosDomain {
  (Get-WMIObject Win32_NTDomain -ea 0).DomainName
}

function Get-LocalUserList() {
  [string]$netusers = net users 
  $netusers = $netusers -replace '.*---------\s*(.*)\s*The command completed successfully.\s*', '$1'
  [string[]]$netusers.trim() -split '\s+'
  #[string[]]($users -split '\n')
}

function LocalUserExists([string]$user, [string []]$userlist = @()) {
  if ($userlist.length -eq 0) { [string[]]$userlist = Get-LocalUserList}
  $userlist -contains $User
}

function Delete-LocalUser([string []]$users) {
  foreach ($user in $users) {
    $result = net user $user /delete 2> $null
  }
  -not (LocalUserExists $users[0])
}

  
function Add-UserToGroup ([string]$user, [string]$group='Administrators') {
  $result = net localgroup $group $user /add 2> $null
  write-log "$(FLINE) User: $User Group: $Group Result: $Result"
}


function Add-GroupMember {
  [CmdletBinding()]Param(
    [Alias('LocalGroup','Parent')][string[]]$Group=@('Administrators'), 
    [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
    [Alias('User','GlobalGroup','DomainGroup','Child')][string[]]$Member
  ) 
  begin {}
  process {
	  $Group | % {
		  $Group = $G
		  $Member | % {
				$result = net localgroup $G $Member /add 2>&1
				write-log "$(FLINE) Member: $Member Group: $G Result: $Result"
			}	
		}
  }
	#	write-verbose "$Group contains:`n$(net localgroup $Group) 2>&1)"
  end {}
}

function Add-LocalUser([string]$user, [string]$password, [string]$comment="") {
  if (!$comment) { 
    ## if (!$Customer) { $Customer = 'BUILD' }
    $comment = "" 
  }
  $user = $User.trim() 
  if (!$comment) {$comment = "Auto-created user"}
  if (LocalUserExists) {   # just set password and description
    $result = net user "$user" "$password" "/comment:$comment"      2> $null
  } else {                 # add user with password and description
    $result = net user "$user" "$password" "/comment:$comment" /add 2> $null
  }
  LocalUserExists $user
}`


Function Get-TempPassword() {
  $uppercase   = (65..90  | % {[char]$_})
  $lowercase   = (97..122 | % {[char]$_})
  $alphabet    = ($uppercase + $lowercase)
  $specialchar = ('!@*._?+~=-'  -split '' | ? {$_ })  # '!@$._?+~=:'
  $digits      = ('0123456790'  -split '' | ? {$_ })
  $character   = $alphabet + $specialchar + $digits
  [int]$length = 10
  [string[]]$password = ($character | Get-Random -count 10) 
  $password += ($digits      | Get-Random -count 2) 
  $password += ($specialchar | Get-Random -count 2) 
  return ($password -join '')
}

Function Get-TempName([UINT16]$Length=8, [switch]$Alphabetic, [switch]$Numeric) {
  $uppercase   = (65..90  | % {[char]$_})
  $digits      = ('0123456790'  -split '' | ? {$_ })
  $character   = ''
  if     ($Alphabetic) {$character = $uppercase}
  elseif ($Numeric)    {$character = $digits}
  else   {$character = $uppercase + $digits}
  [string[]]$temp = ($character | Get-Random -count $Length) 
  $temp -join ''
}

function Get-RegValue([String] $KeyPath, [String] $ValueName) {
  (Get-ItemProperty -LiteralPath $KeyPath -Name $ValueName).$ValueName
}

function Get-AdminRole() {
  $Admin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
  echo "Local: $(Get-Date) AdminRole: $Admin" >AdminRoleLog.txt
  if (!$Admin) {$Admin = $false}
  $Admin
}

function Copy-DirectoryTree([string]$sourcepath, [string]$destpath) {
  $xcresult = xcopy $sourcepath $destpath /s /d /y /r /h 2>&1
  $xcresult = $xcresult -join "`n  "
  write-log "$(LINE) Copy-DirectoryTree`n$xcresult" 0
}

function Remove-Parameters {
  param([hashtable]$Source, [string[]]$Remove, [switch]$CommonParameters)
  $Common = @(   # complete list as of PowerShell 5.0 
    'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 
    'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable',
    'Verbose', 'WarningAction', 'WarningVariable', 
    'WhatIf', 'Confirm'  # Risk Mitigation parms
  )
  if ($CommonParameters) {$Remove += $Common}
  write-log "$(LINE) Remove-Parameters length : $($Source.count)" 1
  foreach ($f in $Remove) {if ($Source.ContainsKey($f)) {$Source.Remove($f)}}
  write-log "$(LINE) Remove-Parameters length : $($Source.count)" 1
  $Source
}


function Get-PresentSwitchName([string[]]$switch) {
  $switches = @()
  foreach ($a in $switch) {
    $a = $a -replace '^-',''
    $v = get-variable $a
    if ($v.value) {
      $switches += "-$a"
    }  
  }
  $switches -join ' '
}

function Get-SerialNumber {
  (Get-WmiObject win32_bios  -ea 0 -wa 0).serialnumber -replace '\s+',''
}

function Get-MACAddress {
  (Get-WmiObject win32_networkadapterconfiguration  -ea 0 -wa 0 | 
    ? {$_.description -match 'net' -and $_.macaddress -match ':' }).macaddress -join ';'  # 00:50:56:B9:7A:43
}

function Get-UUID {
  if ($csp = gwmi win32_computersystemproduct -ea 0 -wa 0) {$csp.uuid} else {''}
}

function New-UniqueName() { [System.IO.Path]::GetRandomFileName() }  
               
function New-TemporaryDirectory ([string]$Path = '.\temp', [switch]$Create) {
  if (!$Path) { $Path = '.' }
  $tempDir = join-path $Path New-UniqueName
  if ($Create) {$dirResult = mkdir $tempDir -force -ea 0 -wa 0}
  If (Test-Path $tempDir) { $tempDir } else { '' }
}  

#(Get-Date -f "yyyy-MM-dd-ddd-HH:mm:ss")
#2016-12-22-Thu-10:21:40
#
#(Get-Date -f "yyyy-MM-dd")
#2016-12-22

#endregion Definitions

#endregion Script Diagnostic & utility Functions

function testlog () {
  write-log @args
  write-log "$(FILE):$(LINE) Testlog"
}

function testfl () {
  write-host @args
  write-host "$(FILE):$(LINE) Testlog"
}

function Set-ExecutionPolicyRemotely([string]$Computername, [string]$ExecutionPolicy, $cred) {
  if ($ExecutionPolicy -notmatch 'Unrestricted|RemoteSigned|AllSigned|Restricted|Default|Bypass|Undefined') 
    { $ExecutionPolicy = 'RemoteSigned' }
  # reg add HKCU\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d ByPass /f 
  $EnableExec = "reg add HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell " +
                "/v ExecutionPolicy /t REG_SZ /d $ExecutionPolicy /f"
  write-log "$(LINE) Attempt to enable ExecutionPolicy: $ExecutionPolicy"
  try {
    $proc = Invoke-WmiMethod `
      -ComputerName $Computername `
      -Class Win32_Process `
      -Name Create -ea 0 -ev WMI `
      -ArgumentList $EnableExec `
      -Impersonation 3 -EnableAllPrivileges -cred $Cred
  } catch {
    write-log "$(LINE) Catch and Ignore WMI error Attempt to enable ExecutionPolicy"
  }  
}

function Set-FirewallOff {
  [CmdLetBinding()]param(
    [string]$Computername, 
    $cred
  ) 
  $FirewallOff = @("netsh advfirewall set allprofiles state off","cmd /c c:\AppDirectory_windows\FireWallState.cmd")
  try {
    foreach ($arg in $FireWallOff) {
      write-log "$(LINE) Attempt to set FIREWALL OFF: $arg"
      $proc = Invoke-WmiMethod `
        -ComputerName $Computername `
        -Class Win32_Process `
        -Name Create -ea 0 -ev WMI `
        -ArgumentList $arg `
        -Impersonation 3 -EnableAllPrivileges -cred $Cred
      write-log "$(LINE) Set-FirewallOFF result: [$($proc | select ProcessId,ReturnValue)] : $arg"
    }  
  } catch {
    write-log "$(LINE) Catch and Ignore WMI error Attempt to set FIREWALL OFF"
  }  
}

function Get-OS {(Get-WmiObject -class Win32_OperatingSystem -ea 0).caption}
function Is-Windows2008? {return ((Get-OS) -match '2008')}

function Get-EnvironmentVariable([string] $Name, [System.EnvironmentVariableTarget] $Scope) {
  [Environment]::GetEnvironmentVariable($Name, $Scope)
}

function Get-EnvironmentVariableNames([System.EnvironmentVariableTarget] $Scope) {
  switch ($Scope) {
    'User'    { Get-Item 'HKCU:\Environment' | Select-Object -ExpandProperty Property }
    'Machine' { Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' | Select-Object -ExpandProperty Property }
    'Process' { Get-ChildItem Env:\ | Select-Object -ExpandProperty Key }
    default { throw "Unsupported environment scope: $Scope" }
  }
}

function Update-Environment {
<#
.SYNOPSIS
Updates the environment variables of the current powershell session 
with any environment variables from the registry.
.DESCRIPTION
During installation the environment may have changed.
Update-Environment refreshes the Powershell session environment
based on current (new) settings in the registry.
#>
  Write-Debug "Running 'Update-Environment' - Updating environment variables"
  'Machine', 'User' |  #ordering is important, user overrides computer settings
    % {
      $scope = $_
      Get-EnvironmentVariableNames -Scope $scope |
        % { Set-Item "Env:$($_)" -Value (Get-EnvironmentVariable -Scope $scope -Name $_) }}
  $paths = 'Machine', 'User' |  #Path gets special treatment: merge uniquely
    % {
      (Get-EnvironmentVariable -Name 'PATH' -Scope $_) -split ';'
    } |
    Select -Unique
  $Env:PATH = $paths -join ';'
}

#Adapted from https://gist.github.com/altrive/5329377
#Based on <http://gallery.technet.microsoft.com/scriptcenter/Get-PendingReboot-Query-bdb79542>
function Is-RebootPending? {
  [string[]]$PendingReboot = @()
  if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { 
    $PendingReboot += 'Component Based Servicing'
  }
  if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { 
     $PendingReboot += 'Windows Update\Auto Update'
  }
  if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) {
     $PendingReboot += 'Session Manager - PendingFileRenameOperations'
  }
  try { 
    $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
    $status = $util.DetermineIfRebootPending()
    if (($status -ne $null) -and $status.RebootPending){
      $PendingReboot += 'clientsdk:CCM_ClientUtilities'
    }
  } catch { }
  return ($PendingReboot -join ';')
}

function Clear-All-Event-Logs ($ComputerName="localhost") {
  try { write-log "$(FLINE) Clear all event logs on $Computername" 2} catch {}
  try {
    Get-EventLog -ComputerName $ComputerName -List -AsString -ea 0 | 
      ? { $_ -notmatch 'Security' }                              |
      % { Clear-EventLog -Comp $ComputerName -Log $_ -ea 0 }
    $null = Clear-EventLog -Comp $ComputerName -Log 'Security' -ea 0
  } catch {}
}


function WaitFor-WSMan {
  [CmdletBinding()]param($ComputerName, $wait=180, $credential)
  if (!$wait) {$wait = 60} # default is 180 but if blank or 0 wait this long
  $Stop = ($start = get-date).AddSeconds($wait)
  $WSManOk = $Authenticated = $Connected = $false  
  write-log "$(LINE) Start: $start Stop: $Stop Wait: $((get-date) -le $Stop)" 1
  $AccessCheckedOk = $true
  while ((get-date) -le $Stop) {
    write-log "$(LINE) Start: $start Stop: $Stop WSManOk: $WSManOk Auth: $Authenticated Connected: $Connected" 1
    if ($credential -and $AccessCheckedOk) {
      $resultAuthenticate = test-wsman $ComputerName -cred $credential -auth negotiate -ev wsmanError -ea 0
      $WSManOk = $Connected = $Authenticated = $? # 
      if ($wsManError -match 'Access is denied') { $AccessCheckedOk = $False }
      $resultAuthenticate = ($resultAuthenticate | out-string) -replace '(^\s+)|(\s+$)' 
      if ($lastAuthenticate -ne $resultAuthenticate) { write-log "$(LINE) Authenticate`n$resultAuthenticate" }
      $lastAuthenticate = $resultAuthenticate
    } 
    if (!$Authenticated) {
      $resultConnect = test-wsman $ComputerName -ev wsmanError -ea 0
      $Connected = $?
      $WSManOk = !$Credential -and $Connected
      $resultConnect = ($resultConnect | out-string) -replace '(^\s+)|(\s+$)' 
      if ($lastConnect -ne $resultConnect) { write-log "$(LINE) Start: $start Now: $(get-date) Stop: $Stop WSManOk: $WSManOk Auth: $Authenticated Connected: $Connected `n$resultConnect" 1}
      $lastConnect = $resultConnect
    }   
    if ($WSManOk) { break } 
    if ($Connected -and !$AccessCheckedOk) {break}
    Sleep -s 5   
  } 
  $result = "`n$resultAuthenticate$resultConnect"
  write-log "$(LINE) Start: $start Now: $(get-date) Stop: $Stop WSManOk: $WSManOk Auth: $Authenticated Connect: $Connected$Result" 1
  $WSManOk -and $AccessCheckedOk   # If No $Credential $AccessCheckedOk will always be $True
}

function Test-Json {
  [CmdletBinding()]param([string[]]$Json, [string]$Caller)
  write-log "$(FLINE) Test-Json called before clean:`n$Json"
  $Json = $Json -join "`n"
  if ($Json -match "What if:[^`n]*`n") { $Json = $Json -replace "(?-i)(What if:|WARNING:|newly-installed role|Update\.)[^`n]*`n" }
  $FoundCurlyBracket = $null; 
  $Json = $Json | ? { $FoundCurlyBracket -or ($FoundCurlyBracket = $_ -match '^\s*{') }    #$Json = $Json -replace '(?sm)^[^{]*'
  $Json = $Json -replace '([^\\])\\([^\\])', '$1\\$2'
  $Json = ($Json -split "`n" | ? { $_ -notmatch '^\s*(True|False|(\d+))?\s*$'} |
                               ? { $_ -notmatch '^\s*\\' } )  -join "`n" 
  write-log "$(FLINE) Test-Json called after clean:`n$Json"
  try {
    $object = $Json | ConvertFrom-Json -ea 0 -ev JsonError
    if ($JsonError) {
      try { write-log "$(FLINE) JsonERROR Test-Json: $($_ | ConvertTo-Json -ea 0)" }
      catch {} # give up
      return ''
    } else {
      $js = $object | convertto-json -depth 10 -ea 0
      #write-log "$(FLINE) Return GOOD Test-Json: `n$JS"}
      return $js  
    }  
  } catch {
    try { write-log "$(FLINE) Caught Test-Json error: $($_ | ConvertTo-Json -ea 0)"}
    catch {} # give up
    return ''
  }
}

function Get-CharSet ([string]$start='D', [string]$end='Q') { 
  ([uint16][char]$start[0]..[uint16][char]$end[0] | % {[char] $_}) -join ''
}

function Get-UnusedDriveLetter($LetterSet) {
  if (!$LetterSet) { $LetterSet = Get-CharSet }
  foreach ($l in (get-psdrive -psprovider filesystem | % {$_.name})) {
    $LetterSet = $LetterSet -replace $l, ''
  }
  $LetterSet
}

                                                                              
                      
                      
 

function Get-ServiceStatus ($Name) {
  $Service = get-service $Name -ea 0
  if ($Service) { return $Service.Status }
  'NotFound'
}

Function Write-ImageInfoLog([string]$CorrelationID, [string]$IPAddress, 
                          [string]$ComputerName, [string]$OS='Unspecified', [string]$LogDir='C:\APP\Log') {
  #'de4bc1cc-2b55-4342-8495-aebcaea7' -match '^[-a-f0-9]{24,38}$'
  If (! ($IPAddress -and $ComputerName -and ($CorrelationID -match '^[-a-f0-9]{24,38}$'))) { return }
  If ($Env:ComputerName -match '^APIN') { $Relay = 'ADC' } else { $Relay = 'SDC' }
  if ($OS -match 'Linux') {$OS = 'Linux'} else { $OS = 'Windows' }  
  $line = [pscustomobject]@{
    'DateTime'      = (Get-Date -f "yyyy-MM-dd\tHH:mm:ss")
    'CorrelationID' = $CorrelationID
    'IPAddress'     = $IPAddress
    'ComputerName'  = $ComputerName
    'OS'            = $OS -replace '\s+', '_'
    'User'          = $Env:Username -replace '\s'
    'Relay'         = $Relay
  }
  $Log = (Join-Path $LogDir 'BuildLog.txt')
  $line | Export-Csv -Path $Log -Append -NoTypeInformation -ea 0 -force -enc ASCII
}

function Get-HostsContent ($path="$Env:SystemRoot\System32\drivers\etc\hosts") { gc $path -ea 0 }

function Replace-HostRecord ([string[]]$hosts, [string]$IP, [string[]]$Name, [string]$comment) {
  if ($hosts.count -gt 0) {
    foreach ($r in 0..($hosts.count - 1)) {
      $h = (($hosts[$r]).trim() -replace '#.*') -replace '^[\.\d]'  
      if ($h) {
        $found = $h -split '\s+'
        foreach ($n in $found) { 
          if ($n -and ($n -in $Name)) {
            $hosts[$r] = "$ip " + ($Name -join ' ') + $comment
            return $hosts
          }  
        }
      }
    } 
  }  
  ''  
}

function Add-HostRecord ([string]$IP, [string[]]$Name, [string]$comment='') {
  if ($comment) { $comment = " # $comment" }
  $newEntry = "$ip " + ($Name -join ' ') + $comment
  $hosts = Get-HostsContent 
  if ($new = Replace-HostRecord $hosts $IP $Name $comment) { $hosts = $new }
  else { $hosts += @($newEntry) } 
  Set-Content -value $hosts -path "$Env:SystemRoot\System32\drivers\etc\hosts" -force -ea 0
  $regexEntry = '^' + [regex]::Escape($newEntry)
  [boolean]((Get-HostsContent) -match $regexEntry)
}

function Sort-ConnectionSpeed {
  [CmdletBinding()]param(
    [Alias('IPAddress','Host','Server')][string[]]$Computername, 
    [int[]]$Port=@(53,88,135,389,445,464,636),
    [Alias('AllOpen')][switch]$OnlyOpen,
    [switch]$AnyOpen
  ) 
  try {
    if (!$Computername) { $Computername = (nslookup txdcs.teamibm.com. | ? {$_} | select -last 4).trim() }
    $Computers = $Computername -join ','
    $ports     = $port -join ','
    $portcheck = @(where.exe portcheck.exe 2>$null)[0]
    $pcArgs    = @('-w', '5000', $Computers, $ports) # -w 3000 = wait 3 seconds
    write-log "$(LINE) $portcheck $($pcArgs)"
    $pcresult  = &$portcheck $pcArgs
    if ($AnyOpen)  { $pcresult = $pcresult | ? {$_ -match 'open'} }
    if ($OnlyOpen) { $pcresult = $pcresult | ? {$_ -notmatch 'closed'} }
    $pcresult | % {($_ -split '\s+')[0]}
  } catch {
    write-log "$(FLINE) Caught error in Sort-Connectionspeed"
  }  
} 

Function ConvertTo-QuotedElementString {
  [CmdLetBinding(PositionalBinding=$False)]
  param(
    [Alias('Separator','Delimiter')][Parameter()]$OFS=$(Get-Variable OFS -scope 1 -ea ignore -value),
    [Parameter()]        $Quotes="'",
    [Parameter()][switch]$DoubleQuotes,
    [Parameter()][switch]$SingleQuotes,
    [Parameter()][switch]$NoQuotes,
    [Parameter()][switch]$WrapSingle,
    [Parameter()][switch]$WrapDouble,
    [Alias('OppositeQuote','OtherQuote')][Parameter()][switch]$WrapOpposite,
    [parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]$Args
  )
  If (!$OFS) { $OFS = ', ' }
  $q = Switch ($True) {
    { $DoubleQuotes }  { '"'; break }
    { $SingleQuotes }  { "'"; break }
    { $NoQuotes     }  { "";  break }
    Default { $Quotes }
  }
  If ($WrapOpposite) {
    $Wrapper = If ($q -eq "'") { '"' } else { "'" }
  } else {
    $Wrapper = Switch ($True) {
      { $WrapDouble }  { '"'; break }
      { $WrapSingle }  { "'"; break }
      Default { '' }
    }
  }
  if ($args.count -eq 1 -and $args[0] -is [object[]]) {
    $args = $args[0]
  }
  "$Wrapper$(($args | ForEach-Object { "$q$_$q" }) -join $OFS)$Wrapper"
}
<#
ConvertTo-QuotedElementString '' -wrapsingle -opp
convertto-quotedelementstring (dir *.ps1).name
convertto-quotedelementstring (dir *.ps1).name -sep ';'
convertto-quotedelementstring (dir *.ps1).name -sep ';' -quote ''
ConvertTo-QuotedElementString 1, 2, 3 
ConvertTo-QuotedElementString 1, 2, 3  x y z -opp -sep ", "
ConvertTo-QuotedElementString 1, 2, 3 -opp -sep ", "
ConvertTo-QuotedElementString 1, 2, 3 -opp -sep ",`t"
ConvertTo-QuotedElementString a 
ConvertTo-QuotedElementString a b c 
ConvertTo-QuotedElementString a b c -wrapdouble
ConvertTo-QuotedElementString a b c -wrapdouble -opp
ConvertTo-QuotedElementString a b c -wrapsingle -opp
ConvertTo-QuotedElementString a -wrapsingle -opp
ConvertTo-QuotedElementString -OFS '|' a b c 
ConvertTo-QuotedElementString -OFS '|' a b c -quote ''
ConvertTo-QuotedElementString 'the string' 1 2 3 -opp -sep ",`t"
ConvertTo-QuotedElementString 'the string' 1 2 3 -wrapsingle -opp
ConvertTo-QuotedElementString 'the string' 1 2 3 -wrapsingle -opp -sep ",`t"
ConvertTo-QuotedElementString 'the string' 1 2 3 -wrapsingle -opp -sep "`t"
ConvertTo-QuotedElementString 'the string' 1 2 3 -wrapsingle -opp -sep '===='
ConvertTo-QuotedElementString 'the string' -wrapsingle -opp

#>
