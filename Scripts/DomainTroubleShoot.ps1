$s = import-csv .\Server-478.csv ; $s[0] | gm -mem noteproperty

# https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/564dc969-6db3-49b3-891a-f2f8d0a68a7f


$Inactive = dsquery computer -inactive 4 -stalepwd 28 -limit 9999 # 4 weeks inactive & 28 days pwd
$Inactive.trim('" ') -replace '(^CN=)|(,CN=[^,]+)' | 
  ForEach-Object { $_ -split ',DC=' -join '.' }    |
  Select-Object -First 10 | nslookup $_
$Inactive = dsquery computer -inactive 4 -stalepwd 28 -limit 9999 # 4 weeks inactive & 28 days pwd
$Inactive.trim('" ') -replace '(^CN=)|(,CN=[^,]+)' | 
  ForEach-Object { $_ -split ',DC=' -join '.' }    |
  Select-Object -First 10 | 
  ForEach-Object { $IP = "$(dig "$_." +short)"; portcheck $_ 135,445,3389 }

$Inactive = dsquery computer -inactive 4 -stalepwd 28 -limit 9999 # 4 weeks inactive & 28 days pwd
$Inactive.trim('" ') -replace '(^CN=)|(,CN=[^,]+)' | 
  ForEach-Object { $_ -split ',DC=' -join '.' }    |
  Select-Object -First 10 | ForEach-Object { 
    $IP = nslookup "$_." 2>$Null 
    $IP -replace '(^.*Name:\s+)|(Address:\s+)|((\*{3}).*find .*)', $_ 
  }


sfc /scannow
dism /online /cleanup-image /restorehealth
# also try installing the latest cumulative update.
http://www.catalog.update.microsoft.com/Search.aspx?q=KB4039396

Error 0x80073701 installing AD role -- might be language settings

Additional commands for our DC cutovers and checking servers:

# If you can’t demote the OLD DC, the use DCPromo /forceremoval  (or equivalent)
# BUT THEN you must do metadata cleanup before finishing.

<#
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
#>

#Use DNScmd to FIND any dead records for the departing DC:

Function Get-DomainRoleName {  # Server/Workstation & StandAlone/Domain or DC 
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

$Domain = (Get-ComputerDomain).domain; $Domain
# Check the domain zone and the _msdcs zone
dnscmd /enumrecords $Domain .          | findstr /i $env:computername
dnscmd /enumrecords "_msdcs.$Domain" . | findstr /i $env:computername
# If you find a GUID record for the DC, then also recheck the _MSDCS for that GUID:
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

# DNSClient download Nuget pkg & unzip
# Add-Type -Path .\lib\net45\DnsClient.dll
# (Get-DotNetAssembly | ? { $_.fullname -match 'dns|lookupclient' -or $_.exportedtypes -match 'dnsclient' } ).ExportedTypes | findstr /i client
# $DNSClient = New-Object DNSClient.LookUpClient
# $DNSClient | gm
# $DNSClient.Query
# $DNSClient.QueryServer

# Nice doc
# https://www.shellandco.net/blog/2014/08/08/enumerate-all-domains-in-a-forest/ 
# [System.DirectoryServices.ActiveDirectory.forest]::GetCurrentForest().Domains.FindDomainController()  
# [System.DirectoryServices.ActiveDirectory.forest]::GetCurrentForest().Domains.GetAllTrustRelationShips()  
# Name
# ----
# CreateLocalSideOfTrustRelationship
# CreateTrustRelationship
# DeleteLocalSideOfTrustRelationship
# DeleteTrustRelationship
# Dispose
# Equals
# FindAllDiscoverableDomainControllers
# FindAllDomainControllers
# FindDomainController
# GetAllTrustRelationships
# GetDirectoryEntry
# GetHashCode
# GetSelectiveAuthenticationStatus
# GetSidFilteringStatus
# GetTrustRelationship
# GetType
# RaiseDomainFunctionality
# RaiseDomainFunctionalityLevel
# RepairTrustRelationship
# SetSelectiveAuthenticationStatus
# SetSidFilteringStatus
# ToString
# UpdateLocalSideOfTrustRelationship
# UpdateTrustRelationship
# VerifyOutboundTrustRelationship
# VerifyTrustRelationship
# Children
# DomainControllers
# DomainMode
# DomainModeLevel
# Forest
# InfrastructureRoleOwner
# Name
# Parent
# PdcRoleOwner
# RidRoleOwner

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

repadmin /replsummary
repadmin /showrepl * /csv
repadmin /showrepl * /csv | convertfrom-csv | ft
repadmin /showrepl * /csv | convertfrom-csv | select -excl showrepl_COLUMNS | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $_ -replace '\W' } } |  convertfrom-csv | select -excl showrepl_COLUMNS | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '\W' } } |  convertfrom-csv | select -excl showrepl_COLUMNS | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '\s_' } } |  convertfrom-csv | select -excl showrepl_COLUMNS | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+' } } |  convertfrom-csv | select -excl showrepl_COLUMNS | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+' } } |  convertfrom-csv -header $Head | select -excl showrepl_COLUMNS | ft
repadmin /showrepl * /csv # | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+' } } |  convertfrom-csv | select -excl showrepl_COLUMNS | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+}' } { $_ }} |  convertfrom-csv | select -excl showrepl_COLUMNS | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+' } } |  convertfrom-csv -header $Head | select -excl showrepl_COLUMNS | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+' } else { $_ |  convertfrom-csv -header $Head }} | select -excl showrepl_COLUMNS | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+' } else { $_ |  convertfrom-csv -header $Head }} | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+' }} # else { $_ |  convertfrom-csv -header $Head }} | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+' } else { $_ }} # |  convertfrom-csv -header $Head }} | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+|showrepl_INFO,' } else { $_ }} # |  convertfrom-csv -header $Head }} | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+' -replace 'showreplINFO,' } else { $_ }} # |  convertfrom-csv -header $Head }} | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+' -replace 'showreplINFO,' } else { $_ }} # |  convertfrom-csv -header $Head }} | ft
repadmin /showrepl * /csv | % {$Head = '' } { If (!$Head) { $Head = $_ -replace '[\s_]+'; $_ = $_ -replace 'showrepl_INFO,' } else { $_ }} # |  convertfrom-csv -header $Head }} | ft
h | % { $_.commandline }

$Forest  = Get-ADForest
$Domains = Foreach ($d in $Forest.Domains) { Get-ADDomain -Identity $d   
$Domains | Format-Table NetbiosName,ObjectGUID,DistinguishedName,DNSRoot,DomainMode

netsh inter ip show dnsservers
$DNSServer = (netsh inter ip show dns | sls '\b\d+(\.\d+){3}$') -replace '^(.*:)?\s+' | select -uniq

$ComputerDNSDomain = 

System.DirectoryServices.ActiveDirectory
.\dig.exe +noall +answer +additional -t srv  _kerberos._tcp.$(Get-ComputerDomain).
    
nslookup -type=srv _kerberos._tcp.$ComputerDNSDomain
nslookup -type=srv _kpasswd._tcp.$ComputerDNSDomain
nslookup -type=srv _ldap._tcp.$ComputerDNSDomain
nslookup -type=srv _ldap._tcp.dc._msdcs.$ComputerDNSDomain
.\dig.exe -t srv  _kerberos._tcp.txdcs.teamibm.com. # +short

[System.DirectoryServices.ActiveDirectory.forest]::GetCurrentForest()
$ForestName    = 'ww930.my-it-solutions.net'
$ForestContext = [System.DirectoryServices.ActiveDirectory.DirectoryContext]::New('forest', $ForestName)
[System.DirectoryServices.ActiveDirectory.forest]::GetForest($ForestContext)

  Function Get-Forest {
    #[OutputType('PSCustomOBject')]
    [CmdletBinding()]Param(
      [Alias('ForestName')][string[]]$Name           = @(),
                           [switch]  $ComputerForest = $False,
                           [switch]  $BothForests    = $False
    )
    Begin {
      $AlreadySeen = @{}
      If ($BothForests -or $ComputerForest) {
        $Name += (Get-ComputerDomain).Domain
      }
      If ($BothForests -or !$Name) { 
        $Name += $Env:UserDNSDomain
      }
    }
    Process {
      ForEach ($Domain in $Name.trim('.')) {
        nslookup -type=srv "_kerberos._tcp.$($Domain)." | 
          Select-String '^[a-z][^:]+[.\d]{7}$'          | 
          ForEach-Object {
            $a = $_ -split '\s+'
            If (!$AlreadySeen.ContainsKey($a[0])) {
              $AlreadySeen.$($a[0]) = 1  # just remember it
              [PSCustomObject]@{ 
                ComputerName = $a[0] -replace '\..*'
                DNSDomain    = $a[0] -replace '^\w+\.'
                IPAddress    = $a[-1] 
              }
            }
          } 
      }  
    } 
  }
  
  Function Get-DomainController {
    [OutputType('PSCustomOBject')]
    [CmdletBinding()]Param(
      [Alias('DomainName')]
      [string[]]$Name           = @(),
      [switch]  $ComputerDomain = $False,
      [switch]  $BothDomains    = $False
    )
    Begin {
      $AlreadySeen = @{}
      If ($BothDomains -or $ComputerDomain) {
        $Name += (Get-ComputerDomain).Domain
      }
      If ($BothDomains -or !$Name) { 
        $Name += $Env:UserDNSDomain
      }
    }
    Process {
      ForEach ($Domain in $Name.trim('.')) {
        nslookup -type=srv "_kerberos._tcp.$($Domain)." | 
          Select-String '^[a-z][^:]+[.\d]{7}$'          | 
          ForEach-Object {
            $a = $_ -split '\s+'
            If (!$AlreadySeen.ContainsKey($a[0])) {
              $AlreadySeen.$($a[0]) = 1  # just remember it
              [PSCustomObject]@{ 
                ComputerName = $a[0] -replace '\..*'
                DNSDomain    = $a[0] -replace '^\w+\.'
                IPAddress    = $a[-1] 
              }
            }
          } 
      }  
    } 
  }

nslookup -type=srv _kerberos._tcp.ad.portal.texas.gov.
    nslookup gc._msdcs.example.root   xx x _gc._tcp
    nslookup -type=srv _vlmcs._tcp >%temp%\kms.txt   
repadmin /options
PS C:\Users\Herb.Martin> cmd
Microsoft Windows [Version 6.1.7601]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

stop kdc
klist purge
  Current LogonId is 0:0x100412
          Deleting all tickets:
          Ticket(s) purged!
klist -li 0x3e7 purge
  Current LogonId is 0:0x100412
  Targeted LogonId is 0:0x3e7
          Deleting all tickets:
          Ticket(s) purged!
netdom resetpwd /server:xcssandc01.txcloud.local /userd:txcloud\herb.martin /passwordd:* 
netdom query ou /userd txdcs\martinh /passwordD $pw
netdom query fsmo | workstation | server | dc | ou | PDC | trust
netdom verify pcname /domain:domainname
netdom reset pcname /domain:domainname
netdom resetpwd /server:xcssandc01.txcloud.local /userd:txcloud\herb.martin /passwordd:* 
netdom computername $env:computername /enum
netdom computername $env:computername /verify
netdom query trust
  
adsiedit version msds-key

    
docs
$s = import-csv server-478.csv    
$s | ? {$_.PrimaryDomain -match 'txdcs$|txdtools' -and $_.domaincontroller -eq 'true'} | sort primarydomain,company,os | select company,computername,ipaddress,os,primarydomain,location | ft    
Company ComputerName  IPAddress      OS                 PrimaryDomain Location
------- ------------  ---------      --                 ------------- --------
NSS     DCS4AVADWN202 204.67.120.13  Win2012R2 6.3.9600 TXDCS         ADC
NSS     DCS4SVADWN202 204.67.202.16  Win2012R2 6.3.9600 TXDCS         SDC
TxDCS   SPINADWN01    168.58.232.37  Win2003 5.2.3790   TXDCS         SDC/LDC
TxDCS   APINADWN01    168.44.244.61  Win2003 5.2.3790   TXDCS         ADC
TxDCS   SPINADWN232   168.58.233.60  Win2008R2 6.1.7601 TXDCS         SDC/LDC
TxDCS   APINADWN231   168.44.244.43  Win2008R2 6.1.7601 TXDCS         ADC

NSS     DCS4AVADWN201 204.67.120.12  Win2012R2 6.3.9600 TXDTOOLS      ADC
NSS     DCS4SVADWN201 204.67.202.15  Win2012R2 6.3.9600 TXDTOOLS      SDC
TxDCS   SPINADWN202   204.67.202.12  Win2008R2 6.1.7601 TXDTOOLS      SDC
TxDCS   APINADWN202   204.67.120.120 Win2008R2 6.1.7601 TXDTOOLS      ADC
TxDCS   APINADWN201   204.67.120.110 Win2008R2 6.1.7601 TXDTOOLS      ADC
TxDCS   SPINADWN201   204.67.202.11  Win2008R2 6.1.7601 TXDTOOLS      SDC

dcs4avadwn202.txdcs.teamibm.com internet address = 204.67.120.13
apinadwn01.txdcs.teamibm.com    internet address = 168.44.244.61
spinadwn01.txdcs.teamibm.com    internet address = 168.58.232.37
spinadwn232.txdcs.teamibm.com   internet address = 168.58.233.60
apinadwn231.txdcs.teamibm.com   internet address = 168.44.244.43
dcs4svadwn202.txdcs.teamibm.com internet address = 204.67.202.16    

dcs4avadwn201.txdtools.loc      internet address = 204.67.120.12
spinadwn201.txdtools.loc        internet address = 204.67.202.11
spinadwn202.txdtools.loc        internet address = 204.67.202.12
apinadwn201.txdtools.loc        internet address = 204.67.120.110
apinadwn202.txdtools.loc        internet address = 204.67.120.120
dcs4svadwn201.txdtools.loc      internet address = 204.67.202.15
    
spinadwn201.txdtools.loc        internet address = 172.21.202.73
 spinadwn202.txdtools.loc        internet address = 172.21.202.74
apinadwn201.txdtools.loc        internet address = 172.20.202.133


    /SERVER:<ServerName> - Specify <ServerName>
    /QUERY - Query <ServerName> netlogon service
    /REPL - Force partial sync on <ServerName> BDC
    /SYNC - Force full sync on <ServerName> BDC
    /PDC_REPL - Force UAS change message from <ServerName> PDC
    /SC_QUERY:<DomainName> - Query secure channel for <Domain> on <ServerName>
    /SC_RESET:<DomainName>[\<DcName>] - Reset secure channel for <Domain> on <ServerName> to <
    /SC_VERIFY:<DomainName> - Verify secure channel for <Domain> on <ServerName>
    /SC_CHANGE_PWD:<DomainName> - Change a secure channel  password for <Domain> on <ServerNam
    /DCLIST:<DomainName> - Get list of DC's for <DomainName>
    /DCNAME:<DomainName> - Get the PDC name for <DomainName>
    /DSGETDC:<DomainName> - Call DsGetDcName /PDC /DS /DSP /GC /KDC
         /TIMESERV /GTIMESERV /NETBIOS /DNS /IP /FORCE /WRITABLE /AVOIDSELF /LDAPONLY /BACKG
         /SITE:<SiteName> /ACCOUNT:<AccountName> /RET_DNS /RET_NETBIOS
    /DNSGETDC:<DomainName> - Call DsGetDcOpen/Next/Close /PDC /GC
         /KDC /WRITABLE /LDAPONLY /FORCE /SITESPEC
    /DSGETFTI:<DomainName> - Call DsGetForestTrustInformation
         /UPDATE_TDO
    /DSGETSITE - Call DsGetSiteName
    /DSGETSITECOV - Call DsGetDcSiteCoverage
    /PARENTDOMAIN - Get the name of the parent domain of this machine
    /WHOWILL:<Domain>* <User> [<Iteration>] - See if <Domain> will log on <User>
    /FINDUSER:<User> - See which trusted domain will log on <User>
    /TRANSPORT_NOTIFY - Notify netlogon of new transport
    /DBFLAG:<HexFlags> - New debug flag
    /USER:<UserName> - Query User info on <ServerName>
    /TIME:<Hex LSL> <Hex MSL> - Convert NT GMT time to ascii
    /LOGON_QUERY - Query number of cumulative logon attempts
    /DOMAIN_TRUSTS - Query domain trusts on <ServerName>
         /PRIMARY /FOREST /DIRECT_OUT /DIRECT_IN /ALL_TRUSTS /V
    /DSREGDNS - Force registration of all DC-specific DNS records
    /DSQUERYDNS - Query the status of the last update for all DC-specific DNS records
    /BDC_QUERY:<DomainName> - Query replication status of BDCs for <DomainName>
