#[CmdletBinding()]Param($ComputerName='www.google.com',$Port=80)

  Set-StrictMode -Version Latest

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

	Function Test-TCP {
		[CmdLetBinding()]Param(
			[string[]]$ComputerName='127.0.0.1',
			[Uint16[]]$Port=135,
			[Alias('Wait','MaxWait')]$TimeOut=3000,
      [switch]$Fail = $Null
		)
    Begin { 
      Write-Verbose "$($MyInvocation | fl * -Force | Out-String)"
      $StartTime = Get-Date
      $Prefix = "$($MyInvocation.InvocationName){0:HHmm}" -f $StartTime
      $Count = 0
    }
    Process {
      try {
        If ($Fail) { 1/0 }
        ForEach ($Target in $ComputerName) {
          $Port | Foreach {
            $Count++          
            $JobName = "$Prefix$($Count)_" + ($Target -replace '[_\W]+', '_').trim('_') 
            Write-Warning "Start-RSJob -Name $JobName { Test-TCPHelper $Target $_ } -FunctionsToImport Test-TCPHelper}"
                           Start-RSJob -Name $JobName { Test-TCPHelper $Target $_ } -FunctionsToImport Test-TCPHelper 
          }
        }  
      } Catch {
        Write-Warning "Caught: $($_ | FL * -Force | Out-String )"
      }
    }
    End { 
    }
  }

    
<#Write-Verbose "Command line: [$($MyInvocation.Line | Out-String -stream)]"
If ($MyInvocation.Line -notmatch '^\W*\.\W') {
  Test-TCP @PSBoundParameters
}
#>