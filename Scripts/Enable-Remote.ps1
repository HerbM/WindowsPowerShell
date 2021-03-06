
  Function Get-CurrentLineNumber { $MyInvocation.ScriptLineNumber }
  Function Get-CurrentFileName   {
    If ($MyInvocation.PSCommandPath) {
      (Split-Path -leaf $MyInvocation.PSCommandPath), $LineNumber -join ':'
    } Else {
      $Command = If (($InvokedAs = Get-Variable MyInvocation -Scope 1 -ea 0 -value)) {
        $InvokedAs.MyCommand
      } Else { '' }
      "GLOBAL:$($Command)"
    }
  }
  Function Get-CurrentFileLine   {
    $LineNumber = $MyInvocation.ScriptLineNumber
    If ($MyInvocation.PSCommandPath) {
      (Split-Path -leaf $MyInvocation.PSCommandPath), $LineNumber -join ':'
    } Else {
      $Command = If (($InvokedAs = Get-Variable MyInvocation -Scope 1 -ea 0 -value)) {
        $InvokedAs.MyCommand
      } Else { '' }
      "GLOBAL:$($Command):$LineNumber"
    }
  }

Try {
  New-Alias -Name   LINE   -Value Get-CurrentLineNumber -Description 'Returns the current (caller''s) line number in a script.' -force -Option allscope
  New-Alias -Name   FILE   -Value Get-CurrentFileName   -Description 'Returns the name of the current script file.' -force             -Option allscope
  New-Alias -Name   FLINE  -Value Get-CurrentFileLine   -Description 'Returns the name of the current script file.' -force             -Option allscope
} Catch { Write-Warning "$FLINE Caught error unexpectedly"  }


$workdir = "c:\healthcheck_windows"
cd $workdir -ea Ignore
$LogFilePath = "$WorkDir\Enable-RemoteScriptingLOG.txt"
if (Test-Path "$WorkDir\Utility.ps1") {
 . "$WorkDir\Utility.ps1"
} elseif (Test-Path "$WorkDir\Epo\Utility.ps1") {
 . "$WorkDir\Epo\Utility.ps1"
} elseif (Test-Path "$WorkDir\Avamar\Utility.ps1") {
 . "$WorkDir\Avamar\Utility.ps1"
} else {
  "$(get-date) Utility.ps1 did not exist" >> $LogFilePath
	try {
		if (!(get-alias LINE -ea IGNORE)) { # -Option allscope
      if (!(get-command Get-CurrentLineNumber -ea IGNORE)) {
        Function Get-CurrentLineNumber { 'Unknown' }      
      }    
			New-Alias -Name LINE      -Value Get-CurrentLineNumber -force -Option allscope
			New-Alias -Name Write-Log -Value Write-Warning         -force -Option allscope
		}	
	} catch {
    Write-Warning "Utility.ps1 not found."
  } finally {
		if (!(get-command Get-CurrentLineNumber -ea IGNORE)) {
    
    }    
  }
}
#whoami /priv >> $LogFilePath
$admin = ([Security.Principal.WindowsPrincipal]`
 [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
 [Security.Principal.WindowsBuiltInRole] "Administrator")

try {
  $x = netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes 2>&1
} Catch {
  Write-Log "Caught error while setting Network Discovery: $x"
}
write-log "$(LINE) Beginning Enable-RemoteScripting as Admin [$Admin]"
#"$(LINE) Beginning Enable-RemoteScripting as Admin [$Admin]" >> $LogFilePath
$execpol = Get-ExecutionPolicy -Scope LocalMachine
write-log "$(LINE) Check ExecutionPolicy: $execpol"
#"$(LINE) Check ExecutionPolicy: $execpol" >> $LogFilePath
if ($execpol -match 'AllSigned|Restricted|Undefined') {
  write-log "$(LINE) Enable scripting"
  #"$(LINE) Enable scripting" >> $LogFilePath
  Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
  write-log "$(LINE) Enabled scripting"
  #"$(LINE) Enabled scripting" >> $LogFilePath
}
#$s = (get-service 'winrm' -erroraction silentlycontinue)
#if ((-not $s) -or ($s.status -notmatch 'Running')) {
  write-log "$(LINE) Enable Remoting"
  #"$(LINE) Enable Remoting" >> $LogFilePath
  #Set-Item wsman:\localhost\client\trustedhosts * -force
  try {
    Enable-PSRemoting -Force -erroraction silentlycontinue -ev EVRemoting
  } catch {
    write-log "$(LINE) Catch Enable Remoting: $EVRemoting" 
  }
  write-log "$(LINE) Enabled Remoting"
#}
$t = $v = $null
$t = (get-Item wsman:\localhost\client\trustedhosts -erroraction silentlycontinue)
write-log "$(LINE) Trusted hosts check #1: [$t]"
#"$(LINE) Trusted hosts check #1: [$t]" >> $LogFilePath
if ($t) {$v = $t.value}
if ((-not $t) -or (-not $v) -or $v -ne '*') {
  Set-Item wsman:\localhost\client\trustedhosts * -force -erroraction silentlycontinue
  write-log 'Restart winrm service'
#  'Restart winrm service' >> $LogFilePath
  Restart-Service WinRM
  $t = (get-Item wsman:\localhost\client\trustedhosts -erroraction silentlycontinue)
  write-log "$(LINE) Trusted hosts check #2: [$t]"
#  "$(LINE) Trusted hosts check #2: [$t]"  >> $LogFilePath
}
#"$(LINE) Ran as Admin? [$Admin]" >> $LogFilePath
write-log "$(LINE) finished with enable remoting"
#"$(LINE) finished with enable remoting" >> $LogFilePath
get-process -name 'PSEXESVC' -errorac silentlycontinue | stop-process -force
get-process -name 'PSEXEC'   -errorac silentlycontinue | stop-process -force
#$host.SetShouldExit(0)
exit 0


