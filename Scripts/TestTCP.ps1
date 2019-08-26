Set-StrictMode -Version Latest
#Set-StrictMode -OFF

$Source = @"
  using System;
  using System.Net;
  using System.Net.Sockets;
  using System.Collections.Generic;
  public class TCPPort12 {
    
    public static bool IsPortOpen(string host, ushort port, int timeout=3) {
      using(var client = new TcpClient()) {
        try {
          if (timeout < 100) { timeout *= 1000; }
          var timeoutMs = new TimeSpan(0,0,0,timeout);
          var result    = client.BeginConnect(host, port, null, null);
          var success   = result.AsyncWaitHandle.WaitOne(timeoutMs);
          if (!success) { return false; }
          client.EndConnect(result);
        } catch {
          return false;
        } finally {
          if (client.Connected) { client.Close(); }
        }
      }
      return true;
    }

    public static bool TestList(List<string> ComputerName, List<ushort> port, int timeout=3) {
	  ForEach (string Host in ComputerName) {
	    System.Console.WriteLine("{0} {1}", Host, port[0]); 
	  }
    }
    
//      System.Console.WriteLine("Main thread {0} does some work.", wait);
//      System.Console.WriteLine("Main thread catch does some work.", 0);
    
    public static int Add(int a, int b) { return (a + b); }
    public int Multiply(int a, int b)   { return (a * b); }
  }
"@

Add-Type -TypeDefinition $Source
#// [TCPPort8]::Add(4, 3)
#// $BasicTestObject = New-Object TCPPort8
$BasicTestObject.Multiply(5, 2)

return

  <#
  .Example
  (measure-command { test-tcpservice 168.44.245.99 9999 }).TotalSeconds
  .Notes
    Call with many targets on many ports
    Read from command prompt or pipeline or file
    Read a line of file and keep data associated with results
    Parallel both host AND PORT
  #>
  Function Test-TCPPort {  # check actual IP & Port combination
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
      $wait = $iar.AsyncWaitHandle.WaitOne($TimeOut,$false)        # Set timeout
      # Write-Verbose "$(LINE) $(Elapsed) If !Wait"
      if (!$wait) {                                                # Check if connection is complete
          # Write-Verbose "$(LINE) $(Elapsed) NOT Wait"
          #write-log "$(FLINE) Connection Timeout: $Server $Port $TimeOut"
          $Failed = $True
          #try {$tcpclient.EndConnect($iar) | out-Null } catch {}
          # Write-Verbose "$(LINE) $(Elapsed) After ENDConnect"
      }  else {
        # Write-Verbose "$(LINE) $(Elapsed) Wait"
        # $error.Clear()                                           # Close the connection, report any error
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

$Script:OkVersion        = [Version]'1.7.0.0'
$Script:PreferredVersion = [Version]'1.7.4.4'
If ($PoshRSJob = @(Get-Module PoshRSJob -ea Ignore -ListAvailable)) {
  $Script:HighestFound = @($PoshRSJob | Sort Version -desc | Select -first 1 | ForEach Version)
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

# Return:
#   ComputerName
#   IPAddress
#   Status
#   Port
#   Result
#   QueryID
#   Data 

# check 1 IP/port by calling Test-TCPPort
# check file or stream by calling Test-TCP   
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
      $FunctionsToImport = @{ FunctionsToImport = 'Test-TCPPort' }
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
            Write-Warning "Start-RSJob: Test-TCPPort $Name $P "
                    $Job = Start-RSJob @JobArguments { Test-TCPPort $Name $P } @FunctionsToImport
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
                     [string[]]$ComputerName = '',
      [Alias('Address')][string[]]$IPAddress,
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
          ForEach ($P in $Port) {
            $Count++          
            $JobName = "$Prefix$($Count)_" + ($Target -replace '[_\W]+', '_').trim('_') 
            Write-Verbose "Start-RSJob -Name $JobName { Test-TCPPort $Target $P } -FunctionsToImport Test-TCPPort}"
            $Job = Start-RSJob -Name $JobName { Test-TCPPort $Target $P } -FunctionsToImport Test-TCPPort
          }
        }  
      } Catch {
        Write-Warning "Caught: $($_ | FL * -Force | Out-String )"
      }
    }
    End { 
    }
  }