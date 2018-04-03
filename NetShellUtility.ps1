<#
		function Get-InterfaceName
		function Get-BURNetworkInterface
		function Set-InterfaceName
		function Get-NetInterface
		function Set-AllInterfaceNames
		function Find-ProductionInterface
		function Set-ClientDNSServer
		function Get-InterfaceIP
		function Get-AllInterfaceNames
#>

function Get-InterfaceName {
  [CmdletBinding()]
  Param([string[]] $interface) # [Parameter(Mandatory=$true)]
  @($interface | % { ($_ -split '\s+',4)[3]})
}

function Get-BURNetworkInterface {
  $BurIf = $null
  [string[]]$netshellResult = netsh interface ipv4 show address | % { if ($_ -match '(Configuration for interface)|(172.2[01]\.[0-9]+\.[0-9]+$)') {$_}}
  if ($netshellResult.length -gt 1) {
    for ($i=1; $i -lt $netshellResult.length; $i++) {
      if ($netshellResult[$i] -match '(172.2[01]\.[0-9]+\.[0-9]+$)') {
        $BurIf  = $netshellResult[$i-1] -replace '^[^"]+"',''
        $BurIf  = $BurIf                -replace '".*$',''
        break;
      }    
    }  
  }
  $BurIf
}


function Set-InterfaceName {
  [CmdletBinding()]
  Param([string[]] $interface, [string]$newname)      # [Parameter(Mandatory=$true)]
  #"`n"
  if ($interface) {
    $letter = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' -split ''
    if ($interface.length -gt 1) {[string]$id = $i} else {[string]$id = ''}
    $i  = 1
    $bi = 0    
    $BURInterface = Get-BURNetworkInterface
    foreach ($int in $interface) {
      if ($int -eq $BURInterface) {
        [string]$id = $letter[$bi++]  # A, B, C, etc.     
        $cmd =  netsh interface set interface  "$int"  newname="BUR"
      } else {
        [string]$id = $letter[$i++]  # A, B, C, etc.     
        $cmd =  netsh interface set interface  "$int"  newname="$($newname)$id"
      }
    }  
  }  
}

function Get-NetInterface {
  @(netsh interface show interface | ? { $_ -notmatch '^(Admin|--|(.*Loopback.*)|$)'})
}

function Set-AllInterfaceNames {
  $interface    = Get-NetInterface 
  $disconnected = $interface | where {$_ -match 'Enabled\s+Discon'} 
  $connected    = $interface | ? {$_ -match 'Enabled\s+Conn'}
  Set-InterfaceName (Get-InterfaceName $connected)    'PROD-'
  Set-InterfaceName (Get-InterfaceName $disconnected) 'SPARE-'
}

function Import-StandardBuildData {
  [CmdletBinding()]param(
	  [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	  [Alias('PSPath')][string[]]$Path) 
	$Path += @('C:\AppDirectory\BuildData.txt','.\BuildData.txt' )
	$file = dir $Path -ea 0 | select -first 1
	gc $file -ea 0 | convertfrom-json -ea 0	
}
# get-wmiobject Win32_NetworkAdapterConfiguration | ? {$_.MacAddress} |select macaddress,description,servicename,ipaddress
# $bd.server.networkAdapter   $bd.server.networkAdapter.vlan
# $bd.server.networkAdapter.ipaddress
# (get-wmiobject Win32_NetworkAdapterConfiguration | ? {$_.MacAddress} |select ipaddress).ipaddress -match '204'

#Set-AllInterfaceNames
#netsh interface show interface

function Find-ProductionInterface {
  $interface    = Get-NetInterface
  $connected    = $interface | ? {$_ -match 'Enabled\s+Conn'}
  $prod = @(Get-InterfaceName $connected | ? { $_ -notmatch 'BUR|LOOPBACK' })
  #$prod
  $prod[0]
}

function Set-ClientDNSServer {
  [cmdletbinding()]param(
    [parameter(Position=0)][string[]]$IPAddress, 
    [parameter(Position=1)][alias('interface')][string]$name, 
    [switch]$reset
  ) 
  $cmd = 'netsh'
  if ($reset) {
    $arg = @('interface', 'ipv4', 'set', 'dns', "`"$name`"", 'static', 'none', 'validate=no') 
    #[string]$nsResult = netsh interface ipv4 set dns "`"$name`"" static none validate=no 2>&1
    Start-ProcessWithWait $cmd $arg -wait (7 * 1000)
  }
  $IPAddress | % {
    $arg = @('interface', 'ipv4', 'add', 'dns', "`"$name`"", $_, 'validate=no')
    Start-ProcessWithWait $cmd $arg -wait (7 * 1000)
  }    
}

function Get-InterfaceIP {
  $interfaces = Get-NetInterface 
   # @($interface | % { ($_ -split '\s+',4)[3]})
  foreach ($Interface in $interfaces) {
    ($AdminState, $State, $Type, $Name) = $Interface -split '\s+',4
    $int = [ordered]@{
      'Name'            = $Name      
      'DHCP'            = ''
      'IPAddress'       = ''
      'SubnetPrefix'    = ''
      'DefaultGateway'  = ''
      'GatewayMetric'   = ''
      'InterfaceMetric' =  ''
      'AdminState'      = $AdminState
      'State'           = $State
      'Type'            = $Type
    } 
    $netshResult = netsh interface IPv4 show add $name
    foreach ($line in $netshResult) {
      if ($line -match '^\s+([\w\s]+):\s+([^\s]+)') { 
        $value = $matches[1] -replace '\s|enabled'
        $int[$value] = $matches[2]
      }
    }
    #$int
    New-Object PSObject -Property $int
  }  
}
if (![boolean](get-alias Get-InterfaceIPv4 -ea 0)) {
  new-alias Get-InterfaceIPv4 Get-InterfaceIP -force -Option allscope
}

function Get-AllInterfaceNames {
  $interface    = Get-NetInterface 
  $disconnected = $interface | where {$_ -match 'Enabled\s+Discon'} 
  $connected    = $interface | ? {$_ -match 'Enabled\s+Conn'}
}


#$UserName  = ‘DCSAdmin’  # presumes you aren’t using a domain account
#$SecString = Read-Host –AsSecureString –Prompt "Enter password (will be masked with *****"

$sb = [scriptblock]::Create(@'
  $file = dir 'c:\HealthCheck_Windows\Standard Tools\McAfee2018\FramePkg.exe'
  $CmdAgent = (dir 'c:\program files\mcafee\agent\cmdagent').FullName  
  $LastPolicyUpdateTime = $(
    &$CmdAgent -i
  ) -match 'LastPolicyUpdateTime:\s+(.*)' | ? { $_ } | % { 
    $_ -replace 'LastPolicyUpdateTime:\s+' 
  }  
  get-service m[acf][acefst]* | Start-Service
  [pscustomobject]@{
    ComputerName         = hostname
    Services             = (get-service m[acf][acefst]*) -join ','
    Length               = $file.Length
    LastWriteTime        = $file.lastwritetime -f 's'
    LastPolicyUpdateTime = $LastPolicyUpdateTime
    AdminRole            = Get-AdminRole 
    FileName             = $file.name
  }
'@)
$Servers = (gc t.txt).trim()
$Servers = ,'127.0.0.1'
$services = $Servers | ? { $_ } | ForEach-Object { 
  get-service m[acf][acefst]*) | Start-Service
  $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$SecString
  invoke-command -computer $_ -script $sb 
} 
$Services | ft

$UserName  = ‘DCSAdmin’  # presumes you aren’t using a domain account
$SecString = Read-Host –AsSecureString –Prompt "Enter password (will be masked with *****"
$sb = [scriptblock]::Create(@'
  $file = dir 'c:\HealthCheck_Windows\Standard Tools\McAfee2018\FramePkg.exe'
  $CmdAgent = (dir 'c:\program files\mcafee\agent\cmdagent.exe').FullName  
  $LastPolicyUpdateTime = & $CmdAgent -i | ? { 
    $_ -match 'LastPolicyUpdateTime:\s+' } | % {
    $_ -replace '(LastPolicyUpdateTime:\s+)'
  }
  get-service m[acf][acefst]* | Start-Service
  [pscustomobject]@{
    ComputerName         = hostname
    Services             = (get-service m[acf][acefst]*) -join ','
    Length               = $file.Length
    LastWriteTime        = $file.lastwritetime -f 's'
    LastPolicyUpdateTime = $LastPolicyUpdateTime 
    FileName             = $file.name
    CmdAgent             = $CmdAgent
  }
  & $CmdAgent -i
'@)
$Servers = (gc t.txt).trim()
# $Servers = ,'127.0.0.1'
$services = $Servers | ? { $_ } | ForEach-Object { 
  $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$SecString
  # invoke-command -script $sb
  invoke-command -computer $_ -cred $credential -script $sb 
} 
$Services | ft
