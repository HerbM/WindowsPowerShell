<#
.Synopsis
  Request time from NTP Servers, optionally set time locally
.Description
  Request time from NTP Servers, optionally set time locally
.Parameter NTPServer
  List of servers, or strings containing whitespace separated server names, to check
  Defaults to W32Time service NTP Server list if set
  ...or to pool.ntp.org, time.windows.com
.Parameter SetDateTime
  Use offset to set date & time of local computer
.Parameter Force
  Set date & time even if server is not synchronized or offset exceeds maxoffset
.Parameter MaxOffset
  Maximum offset in seconds between local and server time for setting
  1000 seconds by default
  (use -Force to override)
.Notes
  https://www.madwithpowershell.com/2016/06/getting-current-time-from-ntp-service.html
  Import-csv .\Junk\Server-NTPCheck.csv | Sort { [Math]::Abs($_.offset) } | ft
  w32tm /monitor /computers:j204.67.71.10,204.67.184.28,204.67.182.226
  Get-NTPTime (Import-CSV .\Server-DC.csv).ipaddress | Export-CSV .\junk\Server-NTPCheck.csv
  Import-CSV .\Server-DC.csv | Get-NTPTime | ft
  
#>
Function Get-NtpTime {
  [CmdletBinding(SupportsShouldProcess)]Param(
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('ComputerName','HostName','IPAddress')][String[]]$NTPServer = $Null,
    [Alias('Synchronize', 'SetTime')]               [switch]$SetDateTime,
    [Alias('IgnoreOffset','IgnoreMaxOffset')]       [switch]$Force,
                                                    [Double]$MaxOffset = 1000.0
  )
  Begin {
    Set-StrictMode -Version Latest
    $StartOfEpoch = New-Object -TypeName DateTime -ArgumentList (1900,1,1,0,0,0,[DateTimeKind]::Utc)
    If (!$NTPServer) {
      $NTPParameters = 'HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters'
      If (Get-ItemProperty $NTPParameters NTPServer -ea Ignore) {
        $NTPServer = (Get-ItemProperty $NTPParameters NTPServer).NTPServer
      }
      If (!$NTPServer) {
        $NTPServer = @('pool.ntp.org', 'time.windows.com')
      }
    }
    Function Convert-OffsetToLocal {
      Param([Long]$Offset)
      $StartOfEpoch.AddMilliseconds($Offset).ToLocalTime()
    }
    Function ConvertTo-NTPMS {
      Param([Byte[]]$NtpData)
      $IntPart  = [BitConverter]::ToUInt32($NtpData[3..0],0)
      $FracPart = [BitConverter]::ToUInt32($NtpData[7..4],0)
      $FracPart = $FracPart * 1000 / 0x100000000   # convert fractional part by dividing value by 2^32
      $IntPart * 1000 + $FracPart
    }
    Function ConvertTo-EpochMS {
      Param([DateTime]$DateTime)
      ([TimeZoneInfo]::ConvertTimeToUtc($DateTime) - $StartOfEpoch).TotalMilliseconds
    }
    Function Get-NTPServerInfo {
      Param(
        [Byte[]]$NTPData,
        [Object]$Info = $Null
      )
      $Version  = ($NtpData[0] -band 0x38) -shr 3  # Server version number
      Write-Verbose "Version: $Version"
      $Mode     = ($NtpData[0] -band 0x07)         # Server mode (probably 'server')
      Write-Verbose "Mode: $Mode"
      $ModeName = Switch ($Mode) {
        0 { 'Reserved'           }
        1 { 'SymmetricActive'    }
        2 { 'SymmetricPassive'   }
        3 { 'Client'             }
        4 { 'Server'             }
        5 { 'Broadcast'          }
        6 { 'ReservedNTPctrlmsg' }
        7 { 'ReservedPrivate'    }
      }
      Write-Verbose "ModeName: $ModeName"
      $Stratum = $NtpData[1]   # [UInt8] (=[Byte])
      Write-Verbose "Stratum: $Stratum"
      $StratumName = Switch ($Stratum) {
        0                         { 'unspecified/unavailable'    }
        1                         { 'primary(e.g., radio clock)' }
        {$_ -ge 2 -and $_ -le 15} { 'secondary(NTP/SNTP)'        }
        {$_ -ge 16}               { 'reserved'                   }
      }
      Write-Verbose "StratumName: $StratumName"
      $PollInterval = $NtpData[2]              # Poll interval, neareast power of 2
      $PollIntervalSeconds = [Math]::Pow(2, $PollInterval)
      $PrecisionBits = $NtpData[3]             # Precision seconds, nearest power of 2
      [Int]$Precision = If ($PrecisionBits -band 0x80) {
        $PrecisionBits -bor 0xFFFFFFE0         # Signed 8-bit, negative if top bit set, sign extend
      } Else {                                 # unlikely: precision less than 1 second)
        $PrecisionBits                         # top bit clear: use positive value
      }
      $PrecisionSeconds = ('{0:G4}' -f [Math]::Pow(2, $Precision)) -as [double]
      Write-Verbose "Precision: $PrecisionSeconds"
      $LI = ($NtpData[0] -band 0xC0) -shr 6    # Leap Second indicator
      $LItext = Switch ($LI) {
        0 { 'Ok'                       }
        1 { 'Last minute 61 sec'       }
        2 { 'Last minute 59 sec'       }
        3 { 'Server not synchronized)' }
      }
      If ($Info) { $Info | 
        Add-Member -MemberType NoteProperty -Name Version     -Value $Version          -PassThru |
        Add-Member -MemberType NoteProperty -Name Mode        -Value $Mode             -PassThru |
        Add-Member -MemberType NoteProperty -Name ModeName    -Value $ModeName         -PassThru |
        Add-Member -MemberType NoteProperty -Name Stratum     -Value $Stratum          -PassThru |
        Add-Member -MemberType NoteProperty -Name StratumName -Value $StratumName      -PassThru |
        Add-Member -MemberType NoteProperty -Name Precision   -Value $PrecisionSeconds -PassThru |
        Add-Member -MemberType NoteProperty -Name LI          -Value $LI               -PassThru |
        Add-Member -MemberType NoteProperty -Name LIText      -Value $LIText
      } Else {
        $Info = [PSCustomObject]@{
          Version     = $Version
          Mode        = $Mode
          ModeName    = $ModeName
          Stratum     = $Stratum
          StratumName = $StratumName
          Precision   = $PrecisionSeconds
        }
      }
      $Null = Set-DefaultPropertySet $Result @('Server','Status','DateTime','Offset')
      # $Precision = @('Server','Status','DateTime','Offset','Delay','Precision')
      # $Detailed  = @('Server','Status','DateTime','Offset','Delay',
      #                'ModeName','StratumName','Precision','LIText')
      # $Result | Add-Member -MemberType PropertySet -Name Detailed -Value $Detailed
      # $Result | Add-Member -MemberType PropertySet -Name Accuracy -Value $Precision
      Write-Verbose "Show Info"
      Write-Verbose "$($Info | ft | Out-String )"
      $Info
    }
  }
  Process {
    ForEach ($Server in $NTPServer.trim('"'' ') -replace '(,\S*)' -split '\s+') {
      Write-Verbose "Attempting to query time from Server: $Server"
      $Result = [PSCustomObject]@{
        Server   = $Server
        Status   = 'Failure'
        DateTime = ''
        Offset   = ''
        Delay    = ''
      }
      $NTPData    = New-Object byte[] 48  # NTP request packet, Array of 48 bytes set to zero
      $NTPData[0] = 35          # 00100011   32+3   = 35   = 27        # 00011011   16+8+3 = 27
      # Request header: 00 = No Leap Warning; 011 = Version 3; 011 = Client Mode; 00011011 = 27
      $Socket = New-Object Net.Sockets.Socket('InterNetwork', 'Dgram', 'Udp')
      $Socket.SendTimeOut = $Socket.ReceiveTimeOut = 2000  # ms
      Try {
        $Socket.Connect($Server, 123)
        If ($Socket.Connected) {
          $T1   = $SendTime = Get-Date
          $Sent = $Socket.Send($NTPData)
          If ($Sent) {
            If ($Receive = $Socket.Receive($NTPData)) {
              $t4 = $ReceiveTime = Get-Date
              $Seconds         = [BitConverter]::ToUInt32($NTPData[43..40], 0)  # Seconds since "Start of Epoch"
              $Result.DateTime = $StartOfEpoch.AddSeconds($Seconds).ToLocalTime() # Add to "Start of Epoch"
              $t3ms            = ConvertTo-NTPMS $NTPData[40..47]
              $t2ms            = ConvertTo-NTPMS $NTPData[32..39]
              $t1ms            = ConvertTo-EpochMS $T1
              $t4ms            = ConvertTo-EpochMS $T4
              $OffsetMS        = (($t2ms - $t1ms) + ($t3ms-$t4ms  ))/2 # Calculate NTP Offset
              $DelayMS         = (($t4ms - $t1ms) - ($t3ms - $t2ms))   # Calculate NTP Delay
              $Result.Offset   = [Math]::Round($OffsetMS / 1000, 3)
              $Result.Delay    = [Math]::Round($DelayMS  / 1000, 3)
              $ServerTimeOk    = $True
              If ([Math]::Abs($Result.Offset) -gt $MaxOffset) {
                $ServerTimeOk = $False
                Write-Warning "Network time offset $($Result.Offset) exceeds maximum $($MaxOffset)ms"
              }
              $Result.Status     = 'Success'
              # $LI = ($NtpData[0] -band 0xC0) -shr 6    # Leap Second indicator
              # $Result.ServerInfo = Get-NTPServerInfo $NTPData
              $Result = Get-NTPServerInfo $NTPData $Result
              If ($Result.LI -eq 3) {
                $ServerTimeOk  = $False
                $Result.Status = 'Unsynchronized'
                Write-Warning "Clock not synchronized: $Server"
              }
              If ($SetDateTime -and ($Force -or $ServerTimeOk)) {
                $Null = Set-Date -Adjust ([timespan]::New(0, 0, 0, $Result.Offset))
              }
            } Else {
              Write-Verbose ("Unable to receive data from $Server")
            }
          } Else {
            Write-Verbose ("Failed to send to $Server")
          }
        } Else {
          Write-Verbose ("Unable to connect to $Server")
        }
      } Catch {
        Write-Verbose ("Exception connecting to $Server`n$_")
      } Finally {
        If ($Socket -and $Socket.Connected) {
          $Socket.Shutdown('Both')
          $Socket.Close()
        }
        $Result
      }
    }
  }
}

<#
$OldNTPServers  = '168.44.244.61,0x1 pool.ntp.org,01x time.windows.com,0x1 168.58.232.37,0x1'
$NTPServersADC  = '204.67.120.40,204.67.120.41,204.67.120.226'
$NTPServersSDC  = '204.67.202.38,204.67.202.39,204.67.202.226'
time.windows.com
pool.ntp.org

time1.google.com
time2.google.com
time3.google.com
time4.google.com

0.pool.ntp.org
1.pool.ntp.org
2.pool.ntp.org
3.pool.ntp.org

time.nist.gov
time-a-g.nist.gov
time-b-g.nist.gov
time-c-g.nist.gov
time-d-g.nist.gov
time-d-g.nist.gov
time-e-g.nist.gov
time-e-g.nist.gov
time-a-wwv.nist.gov
time-b-wwv.nist.gov
time-c-wwv.nist.gov
time-d-wwv.nist.gov
time-d-wwv.nist.gov
time-e-wwv.nist.gov
time-e-wwv.nist.gov
time-a-b.nist.gov
time-b-b.nist.gov
time-c-b.nist.gov
time-d-b.nist.gov
time-d-b.nist.gov
time-e-b.nist.gov
time-e-b.nist.gov
utcnist.colorado.edu
utcnist2.colorado.edu
ut1-time.colorado.edu
ut1-wwv.nist.gov

Function Get-NtpTime {
  [CmdletBinding(SupportsShouldProcess)]Param(
    [Alias('ComputerName','HostName','IPAddress')][String[]]$NTPServer,
    [Alias('Synchronize','SetTime')][switch]$SetDateTime
  )
  Begin {
    $StartOfEpoch = Get-Date('1/1/1900')
  }
  Process {
    ForEach ($Server in $NTPServer) {
      Write-Verbose "Attempting to query time from Server: $Server"
      $Result = [PSCustomObject]@{
        Server = $Server
        Status = 'Failure'
        Time   = ''
        Offset = ''
        Delay  = ''
        ms     = ''
      }
      $NTPData    = New-Object byte[] 48  # NTP request packet, Array of 48 bytes set to zero
      # $NTPData    = New-Object Int64[] 12  # NTP request packet, Array of 48 bytes set to zero
      $NTPData[0] = 35          # 00100011   32+3   = 35
      # $NTPData[0] = 27        # 00011011   16+8+3 = 27
      # Request header: 00 = No Leap Warning; 011 = Version 3; 011 = Client Mode; 00011011 = 27
      $Socket = New-Object Net.Sockets.Socket('InterNetwork', 'Dgram', 'Udp')
      $Socket.SendTimeOut    = 2000  # ms
      $Socket.ReceiveTimeOut = 2000  # ms
      Try {
        $Socket.Connect($Server, 123)
        If ($Socket.Connected) {
          $SendTime = Get-Date
          $Sent    = $Socket.Send($NTPData)
          If ($Sent) {
            If ($Receive = $Socket.Receive($NTPData)) {
              $ReceiveTime   = Get-Date
              #$Seconds       = [BitConverter]::ToUInt64($NTPData[47..40], 0)  # Seconds since "Start of Epoch"
              $Seconds       = [BitConverter]::ToUInt32($NTPData[43..40], 0)  # Seconds since "Start of Epoch"
              $MilliSeconds  = [BitConverter]::ToUInt32($NTPData[47..44], 0)  # Seconds since "Start of Epoch"
              #$Seconds       = $NTPData[10]  # Seconds since "Start of Epoch"
              $Result.ms = $MilliSeconds
              $Result.Time   = $StartOfEpoch.AddSeconds($Seconds).ToLocalTime() # Add to "Start of Epoch"
              #$Result.Time   = $StartOfEpoch.AddSeconds($Seconds).AddMilliSeconds($MilliSeconds).ToLocalTime() # Add to "Start of Epoch"
              $Result.Delay  = ($ReceiveTime - $SendTime).TotalSeconds
              $Result.Offset = ($ReceiveTime - $Result.Time).TotalSeconds
              If ($SetDateTime) {
                $Null = Set-Date -Adjust ([timespan]::New(0,0,-1 * $Result.Offset))
              }
              $Result.Status = 'Success'
            } Else {
              Write-Verbose ("Unable to receive data from $Server")
            }
          } Else {
            Write-Verbose ("Failed to send to $Server")
          }
          $Socket.Shutdown('Both')
          $Socket.Close()
        } Else {
          Write-Verbose ("Unable to connect to $Server")
        }
      } Catch {
        Write-Verbose ("Exception connecting to $Server`n$_")
      } Finally {
        $Result
      }
    }
  }
}




#>
<#
$s = import-csv .\Server-478.csv ; $s[0] | gm -mem noteproperty

# https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/564dc969-6db3-49b3-891a-f2f8d0a68a7f


sfc /scannow
dism /online /cleanup-image /restorehealth
# also try installing the latest cumulative update.
http://www.catalog.update.microsoft.com/Search.aspx?q=KB4039396

Error 0x80073701 installing AD role -- might be language settings

Additional commands for our DC cutovers and checking servers:

If you can’t demote the OLD DC, the use DCPromo /forceremoval  (or equivalent)
BUT THEN you must do metadata cleanup before finishing.

Metadata cleanup, run NTDSUtil, Sites and Services, AD Users/Computers (dsa), and dnscmd:
ntdsutil 
  metadata cleanup
    connections
      connect to server WORKING_DC
      quit
  Select Operation Target
    list sites
    select site N
    list domains in site
    select domain N
    list servers in site
    select server N 
    quit
  Remove selected server
  Quit
Remove from Site in AD Sites & Services
Remove from AD Domain Controllers OU (in DSA ADUC) 

#Use DNScmd to FIND any dead records for the departing DC:

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

#>

Function Get-ComputerDomain {
  Get-WMIObject win32_computersystem |
    Select-Object -property Name,Domain,DomainRole,@{
      N='RoleName';E={Get-DomainRoleName $_.DomainRole}
    }
}

exit

<#
      $Domain = (Get-ComputerDomain).domain
# Check the domain zone and the _msdcs zone
dnscmd /enumrecords $Domain . | findstr /i $env:computername
dnscmd /enumrecords "_msdcs.$Domain" . | findstr /i $env:computername
# If you find a GUID record for the DC, then also recheck the _MSDCS for that GUI you found:
dnscmd /enumrecords "_msdcs.$Domain" . | findstr /i 9befed69-aa2e-4d36-bee2-ab891e8fd34a # <- change to found GUID

      
TIME Service Stuff (beyond the notes we already had):

w32tm /query /source  #check for time source “AllSync” (same as “ALL”)
# Another way to check
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\ /s | findstr /i "ntp all"
	#   reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters
	#			Type    REG_SZ    AllSync
	#			NtpServer    REG_SZ    168.44.244.61 168.58.232.37


# Get Domain Controller list:
$DCs = (netdom query dc | out-string -stream |sls -not '^(The |List |(\s*$))' -case)
# See if they all agree on the FSMO roles:
$DCs | %{ netdom query fsmo /server $_ } | sort            # all DCs should agree
$DCs | %{ netdom query fsmo /server $_ } | sort -uniq  # no role should be listed twice
              $DCs    # show DCs


ntdsutil 
  metadata cleanup
    connections
      connect to server WORKING_DC
      quit
  Select Operation Target
    list sites
    select site N
    list domains in site
    select domain N
    list servers in site
    select server N 
    quit
  Remove selected server
  Quit
Remove from Sites
Remove from AD Domain Controllers OU  
dnscmd /enumrecords txdcs.teamibm.com . | findstr /i $env:computername
dnscmd /enumrecords _msdcs.txdcs.teamibm.com . | findstr /i $env:computername
dnscmd /enumrecords _msdcs.txdcs.teamibm.com . | findstr /i 9befed69-aa2e-4d36-bee2-ab891e8fd34a

#>
$DCs = (netdom query dc | out-string -stream |sls -not '^(The |List |(\s*$))' -case)
$DCs | %{ netdom query fsmo /server $_ } | sort

$FunctionalLevel = @{
  0 = '2000'
  1 = '2003Mixed'
  2 = '2003'
  3 = '2008'
  4 = '2008R2'
  5 = '2012'
  6 = '2012R2'
  7 = '2016'
  8 = '2019'
}

$DomainFunctionalLevel = @{
  '0;0' = '2000Native'
  '0;1' = '2000Mixed'
  '2;0' = '2003'
  '3;0' = '2008'
  '4;0' = '2008R2'
  '5;0' = '2012'
  '6;0' = '2012R2'
  '7;0' = '2016'
  '8;0' = '2019'
}

Function Get-ComputerNetBiosDomain {
  ((nbtstat -n | sls '<00>\s+GROUP' | select -first 1) -split '\s+')[1]  # NetBIOS domain name
}  

Function ConvertTo-DistinguishedName { 
  [CmdLetBinding()]Param($Name = (Get-WMIObject Win32_ComputerSystem).Domain)
  If ($Name -match '^[^.,]+(\.[^.,]+)+\.?$') {   
    'DC=' + (($Name -split '\.') -join ',DC=') 
  } Else {
    $Name
  }  
}         

Function Get-FunctionalLevel {
  [CmdLetBinding()]Param(
    [Alias('DomainName','DName','DNSName','DistinguishedName')]
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
      [string[]]$Name = @(Get-WMIObject Win32_ComputerSystem).Domain,
    [switch]$Detailed = $False,
    [switch]$Dump     = $False,
    [switch]$Expand   = $False
  )
  Begin { $Verbose = [Boolean](Get-Variable Verbose -Scope 0 -ea 0 -Value) }
  Process {
    ForEach ($Domain in $Name) {
      $DN = ConvertTo-DistinguishedName $Domain
      Write-Verbose "Name: $DN"
      $Level        = ([ADSI]"LDAP://$DN").get("MSDS-Behavior-Version")
      $LevelName    = $FunctionalLevel[$Level]
      $ForestRoot   = [ADSI]"LDAP://RootDSE"
      $ForestRootDN = $ForestRoot.get("RootDomainNamingContext")
      $ForestNC     = $ForestRoot.get("configurationNamingContext")
      $ForestLevel  = ([ADSI]"LDAP://cn=partitions,cn=configuration,$ForestRootDN").get("MSDS-Behavior-Version")
      $FFL          = $FunctionalLevel[$ForestLevel]
      $SearchRoot   = [ADSI]"LDAP://CN=Partitions,$ForestNC"
      $AdSearcher   = [adsisearcher]"(&(objectcategory=crossref)(netbiosname=*))"
      $AdSearcher.SearchRoot = $SearchRoot
      $Domains      = @($AdSearcher.FindAll()) # | Select-Object -expand Properties
      ForEach ($Dom in $Domains) {
        $DomainHash = [ordered]@{}
        $DomainProperties = If ($Expand) { $Dom | Select -Expand Properties }
                            Else         { $Dom.Properties                  }
        If ($Dump) { $DomainProperties | Format-Custom -Depth 1 }                    
        ForEach ($Key in $DomainProperties.Keys) {
          $Value = $DomainProperties.Item($Key).Item(0)
          If ($Key -match 'Guid') { 
            $Value = @($Value | % { $_.ToString('X2') }) -join ' ' 
          }          
          Write-Verbose "$Key = $Value [$($Value.GetType())]" 
          $DomainHash.Add($Key, $Value)
        } 
        If ($Dump -or $Verbose) { 
          Write-Warning "$([PSCustomObject]$DomainHash | Format-List | Out-String)" 
        }        
        $FLHash = [Ordered]@{
          Domain                = $Domain
          DomainNetBiosName     = $DomainHash.netbiosName
          DN                    = $DN
          ForestRoot            = $ForestRootDN
          DomainLevel           = $Level
          ForestLevel           = $ForestLevel
          DomainFunctionalLevel = "Win$LevelName"
          ForestFunctionalLevel = "Win$FFL"
        }
        $FLHash += $DomainHash 
        $Result = [PSCustomObject]$FLHash
        Set-DefaultPropertySet $Result @('Domain','DN','DomainFunctionalLevel','ForestFunctionalLevel')
      }
    }
  }
}

<#
  C:\Program Files (x86)\Atos Security outlook button\Application Files\Atos Phishing Button_1_2_7_2SAVE
  
      # ([adsi]'').distinguishedName
      # "$(([adsi]'').distinguishedName)"   # Root
      # [adsi]'' - gets the currect domain root.
      # [adsisearcher]'' gets the searcher.
      # ([adsisearcher]'objectCategory=user').FindAll()
      # ([adsisearcher]'samAccountName=john smith').FindOne()  #search for one user by samname
      # DO something with Domains and their properties      
      # Domain ([ADSI]"LDAP://$DN").get("MSDS-Behavior-Version")
      # Forest ([ADSI]"LDAP://cn=partitions,cn=configuration,$DN").get("MSDS-Behavior-Version")
#>

# $Root = [ADSI]"LDAP://RootDSE"
#$oForestConfig = $Root.Get("configurationNamingContext")
#$oSearchRoot = [ADSI]("LDAP://CN=Partitions," + $oForestConfig)
# $AdSearcher = [adsisearcher]"(&(objectcategory=crossref)(netbiosname=*))"
# $AdSearcher.SearchRoot = $SearchRoot
# $domains = $AdSearcher.FindAll() | Select -expand Properties
# Doesn't work:  ForEach ($Key in $Domains.Keys) { "$Key   :   $($Domains.Key)"  }

$dse = ([ADSI] "LDAP://RootDSE")
$dse.domainControllerFunctionality # Domain Controller Functional Level
$dse.domainFunctionality           # Domain Functional Level
$dse.forestFunctionality           # Forest Functional Level

<#
https://serverfault.com/questions/512228/how-to-check-ad-ds-domain-forest-functional-level-from-domain-joined-workstation/512292#512292

Value  Forest        Domain             Domain Controller
0      2000          2000 Mixed/Native  2000
1      2003 Interim  2003 Interim       N/A
2      2003          2003               2003
3      2008          2008               2008
4      2008 R2       2008 R2            2008 R2
5      2012          2012               2012
6      2012 R2       2012 R2            2012 R2
7      2016          2016               2016
8      2019          2019               2019
#>
# http://www.sysadminlab.net/windows/get-forest-and-domain-functional-level-from-command-line-or-powershell
# https://eightwone.com/references/ad-functional-levels/
# AD Tech Spec
#   https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/d2435927-0999-4c62-8c6d-13ba31a52e1a
# Schema: 
#  dsquery * "CN=Schema,CN=Configuration,$DN" -scope base -attr objectVersion 
#    13 = Windows 2000 Server
#    30 = Windows Server 2003 RTM/SP1/SP2
#    31 = Windows Server 2003 R2
#    44 = Windows Server 2008 RTM
#    47 = Windows Server 2008 R2
#    56 = Windows Server 2012 RTM
#    69 = Windows Server 2012 R2
#    87 = Windows Server 2016
#    87 = Windows Server v1709 (AD DS)    
#    88 = Windows Server v1803 (AD DS)    
#    88 = Windows Server v1809 (AD DS)    
#    88 = Windows Server 2019  (AD DS)     
#
#    30 = ADAM:                            
#    30 = Windows Server 2008    (AD LDS)       
#    31 = Windows Server 2008 R2 (AD LDS) 
#    31 = Windows Server 2012    (AD LDS)       
#    31 = Windows Server 2012 R2 (AD LDS) 
#    31 = Windows Server 2016    (AD LDS)       
#    31 = Windows Server v1709   (AD LDS)     
#    31 = Windows Server v1803   (AD LDS)     
#    31 = Windows Server v1809   (AD LDS)     
<#
https://social.technet.microsoft.com/wiki/contents/articles/16067.nltest-to-test-the-trust-relationship-between-a-workstation-and-domain.aspx
nltest /regdns
nltest /deregdns
nltest 
nltest /DSDEREGDNS:<DnsHostName> /DOM:<DnsDomainName> /DOMGUID:<DomainGuid> /DSAGUID:<DsaGuid>
nltest /bdc_query:txdcs

Start-Job -ScriptBlock {Find-Module} -Name Get-PSGallery 

nltest /dclist:txdcs
       apinadwn01.txdcs.teamibm.com       [DS] Site: Default-First-Site-Name
       spinadwn01.txdcs.teamibm.com       [DS] Site: Default-First-Site-Name
      APINADWN231.txdcs.teamibm.com [PDC] [DS] Site: Default-First-Site-Name
      SPINADWN232.txdcs.teamibm.com       [DS] Site: Default-First-Site-Name
    DCS4AVADWN202.txdcs.teamibm.com       [DS] Site: Default-First-Site-Name
    DCS4SVADWN202.txdcs.teamibm.com       [DS] Site: Default-First-Site-Name

Get-ADForest | select SchemaMaster,DomainNamingMaster
Get-ADDomain | select PDCEmulator,RIDMaster,InfrastructureMaster    
Move-ADDirectoryServerOperationMasterRole -OperationMasterRole SchemaMaster,RIDMaster,InfrastructureMaster,DomainNamingMaster,PDCEmulator -Identity $env:computername -confirm:$false
netsh int ip show int
netsh int ip set dns 12 static 127.0.0.1
netsh int ip add dns 12 168.44.244.43
netsh int ip add dns 12 168.58.233.60
netsh int ip add dns 12 168.58.232.37
netsh int ip show dns 12

dnscmd /zoneexport txdcs.teamibm.com t.txt
dnscmd 10.10.11.30 /zoneexport effcomsys.com t.txt
findstr /i "$($env:computername)" .\t.txt
dnscmd /zoneexport _msdcs.txdcs.teamibm.com ms.txt
findstr /i "$($env:computername)" .\ms.txt

repadmin /showrepl
repadmin /replsummary
  Repadmin Introduction and Technology Overview
  Repadmin Requirements, Syntax, and Parameter Descriptions
  Repadmin Usage Scenarios
  Repadmin for Experts
showrepl_COLUMNS

dnscmd /enumrecords _msdcs.txcloud.local . | select-string '[-a-f0-9]{36}'

repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+'; $_ = $_ -replace 'showrepl_INFO,' } else { $_ }} # |  convertfrom-csv -header $Head }} | ft
h | % { $_.commandline }

$Forest  = Get-ADForest
$Domains = Foreach ($d in $Forest.Domains) { Get-ADDomain -Identity $d   
$Domains | Format-Table NetbiosName,ObjectGUID,DistinguishedName,DNSRoot,DomainMode

netsh inter ip show dnsservers
$DNSServer = (netsh inter ip show dns | sls '\b\d+(\.\d+){3}$') -replace '^(.*:)?\s+' | select -uniq

$ComputerDNSDomain = 
    
nslookup -type=srv_kerberos._tcp.$ComputerDNSDomain
nslookup -type=srv_kpasswd._tcp.$ComputerDNSDomain
nslookup -type=srv_ldap._tcp.$ComputerDNSDomain
nslookup -type=srv_ldap._tcp.dc._msdcs.$ComputerDNSDomain

nslookup -type=srv _kerberos._tcp.ad.portal.texas.gov.
    nslookup gc._msdcs.example.root   xx x _gc._tcp
    nslookup -type=srv _vlmcs._tcp >%temp%\kms.txt   
repadmin /options
PS C:\Users\Herb.Martin> cmd
Microsoft Windows [Version 6.1.7601]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.
#>