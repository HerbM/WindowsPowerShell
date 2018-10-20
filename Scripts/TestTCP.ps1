$Script:OkVersion        = [Version]'1.7.0.0'
$Script:PreferredVersion = [Version]'1.7.4.4'
If ($PoshRSJob = Get-Module PoshRSJob -ea Ignore -ListAvailable) {
$Script:HighestFound = $PoshRSJob | Sort Version -desc | Select -first 1 | ForEach Version
  If (($PoshRSJob.Count -gt 1) -and 
      ($PoshRSJobLoaded = Get-Module PoshRSJob -ea Ignore).Version -lt $Script:HighestFound) {
    Remove-Module PoshRSJob -Force
  }
  Import-Module PoshRSJob -Force -ea Stop
  If ($StartRSJob = Get-Command Start-RSJob -Module PoshRSJob -ea Ignore) {
  } ElseIf ($PoshRSJob.Version -lt $OkVersion) {
    Write-Warning "Older PoshRSJob"
  } ElseIf ($PoshRSJob.Version -lt $PreferredVersion) {
    Write-Warning "PoshRSJob $($PoshRSJob.Version)"
  } Else {
    Write-Verbose "PoshRSJob $($PoshRSJob.Version)"
  }
} Else {
  Write-Warning "PoshRSJob not found"
  Install-Module PoshRSJob -Confirm
}

# Write-Verbose "Returning EARLY....";                return

  Set-StrictMode -Version Latest
  #Set-StrictMode -OFF

  <#
  .Example
  (measure-command { test-tcpservice 168.44.245.99 9999 }).TotalSeconds
  .Notes
    Call with many targets on many ports
    Read from command prompt or pipeline or file
    Read a line of file and keep data associated with results
    Parallel both host AND PORT
  #>
  Function Test-TCPHelper {
    [CmdLetBinding()]Param(
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
      Function Elapsed { param($Start = $Start) '{0,5:N0}ms' -f ((get-date) - $Start).TotalMilliseconds }
      # Write-Verbose "$(LINE) $(Elapsed) Begin"
      $iar = $tcpclient.BeginConnect($Server, $port, $null, $null) # Create Client
      # Write-Verbose "$(LINE) $(Elapsed) Wait"
      $wait = $iar.AsyncWaitHandle.WaitOne($TimeOut,$false)         # Set timeout
      # Write-Verbose "$(LINE) $(Elapsed) If !Wait"
      if (!$wait) {                                                 # Check if connection is complete
          # Write-Verbose "$(LINE) $(Elapsed) NOT Wait"
          #write-log "$(FLINE) Connection Timeout: $Server $Port $TimeOut"
          $Failed = $True
          #try {$tcpclient.EndConnect($iar) | out-Null } catch {}
          # Write-Verbose "$(LINE) $(Elapsed) After ENDConnect"
      }  else {
        # Write-Verbose "$(LINE) $(Elapsed) Wait"
        # $error.Clear()                                             # Close the connection, report any error
        $tcpclient.EndConnect($iar) | out-Null
        # Write-Verbose "$(LINE) $(Elapsed) After End Connect 1"
        if (!$?) {
          # write-Verbose "$(FLINE) $(Elapsed) `$?"
          $failed = $true
        }
      }
    } catch {
      # write-Verbose "$(LINE) $(Elapsed) Catch"
      $Failed = $True
    } finally {
      # write-Verbose "$(LINE) $(Elapsed) Finally"
      if ($tcpclient.Connected) {
        # try {$tcpclient.EndConnect($iar) | out-Null } catch {}
        # write-Verbose "$(LINE) $(Elapsed) After ENDConnect"
        $null = $tcpclient.Close
        # write-Verbose "$(LINE) $(Elapsed) After Close"
      }
    }
    # write-Verbose "$(LINE) $(Elapsed) Returning"
    !$failed  # Return $true if connection Establish else $False
  }

  
  $TargetType = @{
     
  }
  Function Test-TCPSubmit {
    [CmdLetBinding()]Param(
		  [Parameter(Mandatory)][Object[]]$Target, 
			[Uint16[]]$Port=135,
			[string]$JobPrefix = ("$($MyInvocation.InvocationName){0:HHmm}" -f $StartTime),
      [Alias('Wait','MaxWait')]$TimeOut=3000
    )
    Begin { 
		  $Count = 0 
			$FunctionsToImport = @{ FunctionsToImport = 'Test-TCPHelper' }
	  }
    Process {
      try {
        ForEach ($T in $Target) {
				  $Name = $Target.Name
					$Count++
					ForEach ($P in $Port) {
						$JobArguments = @{
							Name = "$($JobPrefix)_" + ($Name -replace '[^.\w]+', '_').trim('_') + "_$P"
							VariablesToImport = 'Name','P'
						}
						Write-Warning "Start-RSJob: Test-TCPHelper $Name $P "
										$Job = Start-RSJob @JobArguments { Test-TCPHelper $Name $P } @FunctionsToImport
						[PSCustomObject]@{
						  Job    = $Job
							Target = $T
							Port   = $P
							Prefix = $JobPrefix
						}	
					}
        }  
      } Catch {
        Write-Warning "Caught: $($_ | FL * -Force | Out-String )"
      }
    }
    End { 
    }
  }

  Function Test-TCP {
    [CmdLetBinding()]Param(
      [string[]]$ComputerName='127.0.0.1',
      [Uint16[]]$Port=135,
      [Alias('Wait','MaxWait')]$TimeOut=3000,
      [switch]$Fail = $Null
    )
    Begin { 
      # Write-Verbose "$($MyInvocation | fl * -Force | Out-String)"
      $StartTime = Get-Date
      $Prefix    = "$($MyInvocation.InvocationName){0:HHmm}" -f $StartTime
      $Count     = 0
			$Jobs      = New-Object System.Collections.ArrayList 
    }
    Process {
      try {
        ForEach ($Computer in $ComputerName) {
          $Port | Foreach {
            $Count++          
            $Mnemonic = "$Prefix$($Count)_" 
						$Target   = New-Object -type PSCustomObject @{ 
						  Name    = $Computer
							Data    = "$Count a string to remember"
						}
						$Job = Test-TCPSubmit $Target $_ $Mnemonic
						[Void]$Jobs.Add($Job) 
          }
        }  
      } Catch {
        Write-Warning "Caught: $($_ | FL * -Force | Out-String )"
      }
    }
    End {       		  
		  #get-rsjob | % { "$($_.id) $($_.Name) $($_.State) [$(Receive-RSJob $_)]" }
		}
  }
	
  Function Test-TCPParse {
    [CmdLetBinding()]Param(
      [Alias('Name','IPAddress','Address','Host','Server','EndPoint')]
                [string[]]$ComputerName = 'local',
      [Alias('Address')][string[]]     $IPAddress,
                     [Uint16[]]   $Port = 135,
      [Alias('Wait','MaxWait')]$TimeOut = 3000,
                        [Object[]]$Data = $Null,
                          [switch]$Fail = $Null
    )
    Begin { 
      #Write-Verbose "$($MyInvocation | fl * -Force | Out-String)"
      #$StartTime = Get-Date
      #$Prefix = "$($MyInvocation.InvocationName){0:HHmm}" -f $StartTime
      #$Count = 0
    }
    Process {
      try {
        If ($Fail) { 1/0 }
        ForEach ($Target in $ComputerName) {
          $Port | Foreach {
            $Count++          
            $JobName = "$Prefix$($Count)_" + ($Target -replace '[_\W]+', '_').trim('_') 
            Write-Verbose "Start-RSJob -Name $JobName { Test-TCPHelper $Target $_ } -FunctionsToImport Test-TCPHelper}"
            $Job = Start-RSJob -Name $JobName { Test-TCPHelper $Target $_ } -FunctionsToImport Test-TCPHelper
          }
        }  
      } Catch {
        Write-Warning "Caught: $($_ | FL * -Force | Out-String )"
      }
    }
    End { 
    }
  }