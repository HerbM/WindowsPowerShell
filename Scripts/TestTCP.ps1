Set-StrictMode -Version Latest
#Set-StrictMode -OFF

$Source = @"
  using System;
  using System.Net;
  using System.Net.Sockets;
  using System.Collections.Generic;
  public class TCPPort12 {
    
    public static bool IsPortOpen(string host, ushort port, uint timeout=3, uint index=0) {
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

# Make 2+ parametersets, default is with ComputerName/hostname, not allowed in IP, this
# will close off the ComputerName parameter making it easier to get the IP setup
# might not work but worth thought.  CN vs IP
# maybe multiple function entries for different parsing/parms
# [IPAddress]  <# WORKS! #>

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
  
Function Since {
  [CmdletBinding()]Param(
    [Parameter(ValueFromPipeline)][Object[]]$InputObject,
    [switch]$LoadOnly
  )
  Begin   {
	$Local:ObjectCount = 0
  }
  Process {
    ForEach ($Object in $InputObject) {
	  $Object.GetType(), $Object.ToString() -join ' '
	  $ObjectCount++
	}
  }
  End     {
    Write-Warning "Object count: $($ObjectCount)"
  }
}
<#	
    $Input | GM
    ForEach ($element in $Input) {
      #"Count: $($Input.count) Input: $element"
      [PSCustomObject]@{
        IPAddress = $IPAddress
        Input     = $Element
      }
    }
#>

  Function Test-TCPParse {
    [CmdLetBinding()]Param(
      [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
      [Alias('Name','HostName','ServerName','EndPoint')][string[]]$ComputerName = '',
      [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
      [Alias('IP Address', 'Address')][string[]]$IPAddress = '',
                                     [Uint16[]]$PortNumber = 135,
      [Alias('Wait','MaxWait')]                   $TimeOut = 3000,
                                           [Object[]]$Data = $Null,
                                        [switch]$ValueOnly = $Null,
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
        If (!$Computername -and $IPAddress) { $ComputerName = $IPAddress }
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
  
<#
function Test-Port{  
<#    
.SYNOPSIS    
    Tests port on computer.  
    
.DESCRIPTION  
    Tests port on computer. 
     
.PARAMETER computer  
    Name of server to test the port connection on.
      
.PARAMETER port  
    Port to test 
       
.PARAMETER tcp  
    Use tcp port 
      
.PARAMETER udp  
    Use udp port  
     
.PARAMETER UDPTimeOut 
    Sets a timeout for UDP port query. (In milliseconds, Default is 1000)  
      
.PARAMETER TCPTimeOut 
    Sets a timeout for TCP port query. (In milliseconds, Default is 1000)
                 
.NOTES    
    Name: Test-Port.ps1  
    Author: Boe Prox  
    DateCreated: 18Aug2010   
    List of Ports: http://www.iana.org/assignments/port-numbers  
      
    To Do:  
        Add capability to run background jobs for each host to shorten the time to scan.         
.LINK    
    https://boeprox.wordpress.org 
     
.EXAMPLE    
    Test-Port -computer 'server' -port 80  
    Checks port 80 on server 'server' to see if it is listening  
    
.EXAMPLE    
    'server' | Test-Port -port 80  
    Checks port 80 on server 'server' to see if it is listening 
      
.EXAMPLE    
    Test-Port -computer @("server1","server2") -port 80  
    Checks port 80 on server1 and server2 to see if it is listening  
    
.EXAMPLE
    Test-Port -comp dc1 -port 17 -udp -UDPtimeout 10000
    
    Server   : dc1
    Port     : 17
    TypePort : UDP
    Open     : True
    Notes    : "My spelling is Wobbly.  It's good spelling but it Wobbles, and the letters
            get in the wrong places." A. A. Milne (1882-1958)
    
    Description
    -----------
    Queries port 17 (qotd) on the UDP port and returns whether port is open or not
       
.EXAMPLE    
    @("server1","server2") | Test-Port -port 80  
    Checks port 80 on server1 and server2 to see if it is listening  
      
.EXAMPLE    
    (Get-Content hosts.txt) | Test-Port -port 80  
    Checks port 80 on servers in host file to see if it is listening 
     
.EXAMPLE    
    Test-Port -computer (Get-Content hosts.txt) -port 80  
    Checks port 80 on servers in host file to see if it is listening 
        
.EXAMPLE    
    Test-Port -computer (Get-Content hosts.txt) -port @(1..59)  
    Checks a range of ports from 1-59 on all servers in the hosts.txt file      
            
#>   
<#
[cmdletbinding(  
    DefaultParameterSetName = '',  
    ConfirmImpact = 'low'  
)]  
    Param(  
        [Parameter(  
            Mandatory = $True,  
            Position = 0,  
            ParameterSetName = '',  
            ValueFromPipeline = $True)]  
            [array]$computer,  
        [Parameter(  
            Position = 1,  
            Mandatory = $True,  
            ParameterSetName = '')]  
            [array]$port,  
        [Parameter(  
            Mandatory = $False,  
            ParameterSetName = '')]  
            [int]$TCPtimeout=1000,  
        [Parameter(  
            Mandatory = $False,  
            ParameterSetName = '')]  
            [int]$UDPtimeout=1000,             
        [Parameter(  
            Mandatory = $False,  
            ParameterSetName = '')]  
            [switch]$TCP,  
        [Parameter(  
            Mandatory = $False,  
            ParameterSetName = '')]  
            [switch]$UDP                                    
        )  
    Begin {  
        If (!$tcp -AND !$udp) {$tcp = $True}  
        #Typically you never do this, but in this case I felt it was for the benefit of the function  
        #as any errors will be noted in the output of the report          
        $ErrorActionPreference = "SilentlyContinue"  
        $report = @()  
    }  
    Process {     
        ForEach ($c in $computer) {  
            ForEach ($p in $port) {  
                If ($tcp) {    
                    #Create temporary holder   
                    $temp = "" | Select Server, Port, TypePort, Open, Notes  
                    #Create object for connecting to port on computer  
                    $tcpobject = new-Object system.Net.Sockets.TcpClient  
                    #Connect to remote machine's port                
                    $connect = $tcpobject.BeginConnect($c,$p,$null,$null)  
                    #Configure a timeout before quitting  
                    $wait = $connect.AsyncWaitHandle.WaitOne($TCPtimeout,$false)  
                    #If timeout  
                    If(!$wait) {  
                        #Close connection  
                        $tcpobject.Close()  
                        Write-Verbose "Connection Timeout"  
                        #Build report  
                        $temp.Server = $c  
                        $temp.Port = $p  
                        $temp.TypePort = "TCP"  
                        $temp.Open = "False"  
                        $temp.Notes = "Connection to Port Timed Out"  
                    } Else {  
                        $error.Clear()  
                        $tcpobject.EndConnect($connect) | out-Null  
                        #If error  
                        If($error[0]){  
                            #Begin making error more readable in report  
                            [string]$string = ($error[0].exception).message  
                            $message = (($string.split(":")[1]).replace('"',"")).TrimStart()  
                            $failed = $true  
                        }  
                        #Close connection      
                        $tcpobject.Close()  
                        #If unable to query port to due failure  
                        If($failed){  
                            #Build report  
                            $temp.Server = $c  
                            $temp.Port = $p  
                            $temp.TypePort = "TCP"  
                            $temp.Open = "False"  
                            $temp.Notes = "$message"  
                        } Else{  
                            #Build report  
                            $temp.Server = $c  
                            $temp.Port = $p  
                            $temp.TypePort = "TCP"  
                            $temp.Open = "True"    
                            $temp.Notes = ""  
                        }  
                    }     
                    #Reset failed value  
                    $failed = $Null      
                    #Merge temp array with report              
                    $report += $temp  
                }      
                If ($udp) {  
                    #Create temporary holder   
                    $temp = "" | Select Server, Port, TypePort, Open, Notes                                     
                    #Create object for connecting to port on computer  
                    $udpobject = new-Object system.Net.Sockets.Udpclient
                    #Set a timeout on receiving message 
                    $udpobject.client.ReceiveTimeout = $UDPTimeout 
                    #Connect to remote machine's port                
                    Write-Verbose "Making UDP connection to remote server" 
                    $udpobject.Connect("$c",$p) 
                    #Sends a message to the host to which you have connected. 
                    Write-Verbose "Sending message to remote host" 
                    $a = new-object system.text.asciiencoding 
                    $byte = $a.GetBytes("$(Get-Date)") 
                    [void]$udpobject.Send($byte,$byte.length) 
                    #IPEndPoint object will allow us to read datagrams sent from any source.  
                    Write-Verbose "Creating remote endpoint" 
                    $remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any,0) 
                    Try { 
                        #Blocks until a message returns on this socket from a remote host. 
                        Write-Verbose "Waiting for message return" 
                        $receivebytes = $udpobject.Receive([ref]$remoteendpoint) 
                        [string]$returndata = $a.GetString($receivebytes)
                        If ($returndata) {
                           Write-Verbose "Connection Successful"  
                            #Build report  
                            $temp.Server = $c  
                            $temp.Port = $p  
                            $temp.TypePort = "UDP"  
                            $temp.Open = "True"  
                            $temp.Notes = $returndata   
                            $udpobject.close()   
                        }                       
                    } Catch { 
                        If ($Error[0].ToString() -match "\bRespond after a period of time\b") { 
                            #Close connection  
                            $udpobject.Close()  
                            #Make sure that the host is online and not a false positive that it is open 
                            If (Test-Connection -comp $c -count 1 -quiet) { 
                                Write-Verbose "Connection Open"  
                                #Build report  
                                $temp.Server = $c  
                                $temp.Port = $p  
                                $temp.TypePort = "UDP"  
                                $temp.Open = "True"  
                                $temp.Notes = "" 
                            } Else { 
                                <# 
                                It is possible that the host is not online or that the host is online,  
                                but ICMP is blocked by a firewall and this port is actually open. 
                                #> 
                                Write-Verbose "Host maybe unavailable"  
                                #Build report  
                                $temp.Server = $c  
                                $temp.Port = $p  
                                $temp.TypePort = "UDP"  
                                $temp.Open = "False"  
                                $temp.Notes = "Unable to verify if port is open or if host is unavailable."                                 
                            }                         
                        } ElseIf ($Error[0].ToString() -match "forcibly closed by the remote host" ) { 
                            #Close connection  
                            $udpobject.Close()  
                            Write-Verbose "Connection Timeout"  
                            #Build report  
                            $temp.Server = $c  
                            $temp.Port = $p  
                            $temp.TypePort = "UDP"  
                            $temp.Open = "False"  
                            $temp.Notes = "Connection to Port Timed Out"                         
                        } Else {                      
                            $udpobject.close() 
                        } 
                    }     
                    #Merge temp array with report              
                    $report += $temp  
                }                                  
            }  
        }                  
    }  
    End {  
        #Generate Report  
        $report 
    }
}
#>               
